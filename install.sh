#!/bin/bash
# LinuxMintHyprlandConfig - Installation Script
# Automates installation of Hyprland dotfiles with backup & restoration

set -euo pipefail

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script metadata
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${REPO_ROOT}/OriginalConfigFolders"
BACKUP_TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_PATH="${BACKUP_DIR}/backup_${BACKUP_TIMESTAMP}"
MANIFEST_FILE="${REPO_ROOT}/uninstall-manifest.txt"

# Counters
SYMLINKS_CREATED=0
CONFIGS_BACKED_UP=0
PACKAGES_INSTALLED=0

# ============================================================================
# LOGGING & OUTPUT HELPERS
# ============================================================================

log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[!]${NC} $*"
}

log_error() {
  echo -e "${RED}[✗]${NC} $*" >&2
}

log_section() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$*${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

exit_with_error() {
  log_error "$1"
  exit 1
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

check_environment() {
  log_section "Pre-Installation Checks"

  if [ ! -f "${REPO_ROOT}/README.md" ] || [ ! -d "${REPO_ROOT}/config" ]; then
    exit_with_error "Script must be run from repository root directory"
  fi

  log_success "Running from correct directory: ${REPO_ROOT}"

  if ! grep -q "^ID=.*debian\|^ID=linuxmint" /etc/os-release 2>/dev/null; then
    exit_with_error "This script only supports Debian-based systems (Linux Mint, Ubuntu, etc.)"
  fi

  log_success "System is Debian-based"
}

# ============================================================================
# DEPENDENCY INSTALLATION
# ============================================================================

install_system_packages() {
  log_section "System Package Installation"

  CORE_PACKAGES=(
    hyprland hyprlock hypridle waybar wofi
    ddcutil swaybg playerctl amixer btop swaync
    libnotify gsettings-desktop-schemas dconf-cli
    gnome-terminal nemo xed git
  )

  OPTIONAL_PACKAGES=(
    code obsidian mpv gnome-calendar pavucontrol
  )

  if ! sudo -v; then
    exit_with_error "Sudo access required for package installation"
  fi

  log_info "Updating package manager..."
  sudo apt update -qq && sudo apt upgrade -y >/dev/null 2>&1

  log_info "Installing core packages..."
  for pkg in "${CORE_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii.*$pkg"; then
      log_info "  Installing: $pkg"
      sudo apt install -y "$pkg" >/dev/null 2>&1 && ((PACKAGES_INSTALLED++))
    fi
  done

  log_success "Core packages installed/verified"

  prompt_optional_packages
}

prompt_optional_packages() {
  log_section "Optional Applications"

  log_info "The following optional applications can be installed:"
  log_info "  • VS Code (code editor)"
  log_info "  • Obsidian (note-taking)"
  log_info "  • MPV (video player)"
  log_info "  • GNOME Calendar (calendar app)"
  log_info "  • PulseAudio Control (pavucontrol)"
  log_info ""

  read -p "Install optional applications? (y/n) [n]: " -r optional_choice
  optional_choice=${optional_choice:-n}

  if [[ ! $optional_choice =~ ^[Yy]$ ]]; then
    log_info "Skipping optional applications"
    return
  fi

  for pkg in code obsidian mpv gnome-calendar pavucontrol; do
    if ! dpkg -l | grep -q "^ii.*$pkg"; then
      log_info "  Installing: $pkg"
      sudo apt install -y "$pkg" >/dev/null 2>&1 && ((PACKAGES_INSTALLED++))
    fi
  done

  log_success "Optional packages installed/verified"
}

# ============================================================================
# PERMISSIONS & CONFIGURATION
# ============================================================================

configure_permissions() {
  log_section "Permissions & Configuration"

  if ! groups | grep -q i2c; then
    log_info "Adding user to i2c group for DDC-CI brightness control..."
    sudo usermod -aG i2c "$(whoami)"
    log_warning "i2c group membership requires logout/login to take effect"
  else
    log_success "User already in i2c group"
  fi

  log_info "Verifying ddcutil access..."
  if command -v ddcutil &>/dev/null; then
    if ddcutil detect >/dev/null 2>&1; then
      log_success "ddcutil display detected"
    else
      log_warning "ddcutil installed but no displays detected (DDC-CI may not be available)"
    fi
  fi
}

# ============================================================================
# BACKUP EXISTING CONFIGURATIONS
# ============================================================================

backup_existing_configs() {
  log_section "Backing Up Existing Configurations"

  local targets=(
    "$HOME/.config/hypr"
    "$HOME/.config/waybar"
    "$HOME/.config/wofi"
    "$HOME/.config/btop"
    "$HOME/.themes"
    "$HOME/.bashrc"
  )

  mkdir -p "$BACKUP_PATH"

  for target in "${targets[@]}"; do
    if [ -e "$target" ]; then
      local rel_path="${target#$HOME/}"
      local backup_target="${BACKUP_PATH}/${rel_path}"

      mkdir -p "$(dirname "$backup_target")"
      cp -r "$target" "$backup_target"

      log_success "Backed up: $target"
      echo "FILE|$target|$backup_target" >> "${BACKUP_PATH}/BACKUP_MANIFEST.txt"
      ((CONFIGS_BACKED_UP++))
    fi
  done

  if [ $CONFIGS_BACKED_UP -gt 0 ]; then
    log_success "Created backup at: $BACKUP_PATH"
  fi
}

# ============================================================================
# SYMLINK CREATION
# ============================================================================

create_dir_symlink() {
  local source=$1
  local target=$2

  if [ ! -d "$source" ]; then
    log_warning "Source not found: $source"
    return
  fi

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    log_warning "Target exists and is not a symlink (skipped): $target"
    return
  fi

  if [ -L "$target" ]; then
    rm "$target"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  log_success "  Symlinked: $target → $source"
  echo "SYMLINK|$target|$source" >> "$MANIFEST_FILE"
  ((SYMLINKS_CREATED++))
}

create_script_symlink() {
  local source=$1
  local target=$2

  if [ ! -f "$source" ]; then
    log_warning "Script not found: $source"
    return
  fi

  chmod +x "$source"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    log_warning "Target exists and is not a symlink (skipped): $target"
    return
  fi

  if [ -L "$target" ]; then
    rm "$target"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  log_success "  Symlinked: $target → $source (executable)"
  echo "SCRIPT|$target|$source" >> "$MANIFEST_FILE"
  ((SYMLINKS_CREATED++))
}

create_all_symlinks() {
  log_section "Creating Symlinks"

  # Config directories
  log_info "Config directories:"
  create_dir_symlink "${REPO_ROOT}/config/hypr" "${HOME}/.config/hypr"
  create_dir_symlink "${REPO_ROOT}/config/waybar" "${HOME}/.config/waybar"
  create_dir_symlink "${REPO_ROOT}/config/wofi" "${HOME}/.config/wofi"
  create_dir_symlink "${REPO_ROOT}/config/btop" "${HOME}/.config/btop"

  # Scripts to ~/.local/bin
  log_info "Scripts to ~/.local/bin:"
  mkdir -p "${HOME}/.local/bin"
  for script in "${REPO_ROOT}"/bin/*.sh; do
    script_name=$(basename "$script" .sh)
    create_script_symlink "$script" "${HOME}/.local/bin/$script_name"
  done

  # GTK Theme
  log_info "GTK theme:"
  create_dir_symlink "${REPO_ROOT}/theme/gtkThemes/Graphite-Dark" "${HOME}/.themes/Graphite-Dark"

  # Wallpaper directory
  log_info "Wallpaper directory:"
  create_dir_symlink "${REPO_ROOT}/wallpaper" "${HOME}/.config/wallpaper"

  log_success "Created $SYMLINKS_CREATED symlink(s)"
}

# ============================================================================
# BASHRC CONFIGURATION
# ============================================================================

configure_bashrc() {
  log_section "Configuring .bashrc"

  if [ ! -f "${HOME}/.bashrc" ]; then
    exit_with_error "~/.bashrc not found"
  fi

  if grep -q "# === HYPRLAND CONFIG START ===" "${HOME}/.bashrc"; then
    log_info "Hyprland configuration already in .bashrc (skipping)"
    return
  fi

  cat >> "${HOME}/.bashrc" << 'EOF'

# === HYPRLAND CONFIG START ===
export PATH="$HOME/.local/bin:$PATH"

# Derive REPO_ROOT from the hypr config symlink
if [ -L "$HOME/.config/hypr" ]; then
  export REPO_ROOT="$(cd "$(readlink "$HOME/.config/hypr")" && cd .. && pwd)"
else
  export REPO_ROOT="$HOME/.config/hypr"
fi

# Brightness level (default)
export BRIGHTNESS=$(brightnessCheck 2>/dev/null || echo "15")

# System tools environment variables
export CURRENT_WALLPAPER="${REPO_ROOT}/wallpaper/wall1.png"
export DEFAULT_FILE=""

# Minimal terminal prompt (purple color)
PS1="\[\033[35m\]❯\[\033[0m\] "
# === HYPRLAND CONFIG END ===
EOF

  log_success ".bashrc configured with PATH export and environment variables"
}

# ============================================================================
# THEME APPLICATION
# ============================================================================

apply_gtk_theme() {
  log_section "Applying GTK Theme"

  if command -v gsettings &>/dev/null; then
    log_info "Setting GTK theme to Graphite-Dark..."

    gsettings set org.cinnamon.desktop.interface gtk-theme "Graphite-Dark" 2>/dev/null && \
      log_success "Cinnamon theme set" || log_warning "Could not set Cinnamon theme"

    gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Dark" 2>/dev/null && \
      log_success "GNOME theme set" || log_warning "Could not set GNOME theme"
  else
    log_warning "gsettings not available, theme must be applied manually"
  fi
}

# ============================================================================
# OBSIDIAN THEME INSTALLATION (OPTIONAL)
# ============================================================================

install_obsidian_theme() {
  log_section "Obsidian Theme Installation (Optional)"

  read -p "Install Obsidian theme? (y/n) [n]: " -r obsidian_choice
  obsidian_choice=${obsidian_choice:-n}

  if [[ ! $obsidian_choice =~ ^[Yy]$ ]]; then
    log_info "Skipping Obsidian theme"
    return
  fi

  local obsidian_paths=(
    "$HOME/.local/share/obsidian"
    "$HOME/snap/obsidian/common/.obsidian"
    "$HOME/.config/obsidian"
  )

  local vault_path=""
  for path in "${obsidian_paths[@]}"; do
    if [ -d "$path/themes" ]; then
      vault_path="$path"
      break
    fi
  done

  if [ -n "$vault_path" ]; then
    log_info "Found Obsidian vault at: $vault_path"
    cp -r "${REPO_ROOT}/theme/Obsidian/pitchBlack" "${vault_path}/themes/"
    log_success "Obsidian theme installed"
  else
    log_warning "Obsidian vault not found in standard locations"
    read -p "Enter custom vault path (or press Enter to skip): " custom_vault
    if [ -n "$custom_vault" ] && [ -d "$custom_vault/themes" ]; then
      cp -r "${REPO_ROOT}/theme/Obsidian/pitchBlack" "${custom_vault}/themes/"
      log_success "Obsidian theme installed at: $custom_vault"
    else
      log_info "Obsidian theme installation skipped"
    fi
  fi
}

# ============================================================================
# HYPRSHOT INSTALLATION (OPTIONAL)
# ============================================================================

install_hyprshot() {
  log_section "Hyprshot Installation (Optional)"

  PS3="Select Hyprshot installation method: "
  options=("Auto install from GitHub" "Manual install (show instructions)" "Skip")
  select opt in "${options[@]}"; do
    case $opt in
      "Auto install from GitHub")
        log_info "Cloning Hyprshot..."
        if git clone https://github.com/Gustash/hyprshot.git "${HOME}/Hyprshot" 2>/dev/null; then
          chmod +x "${HOME}/Hyprshot/hyprshot"
          mkdir -p "${HOME}/.local/bin"
          ln -sf "${HOME}/Hyprshot/hyprshot" "${HOME}/.local/bin/hyprshot"
          echo "HYPRSHOT|${HOME}/.local/bin/hyprshot|${HOME}/Hyprshot/hyprshot" >> "$MANIFEST_FILE"
          log_success "Hyprshot installed at: ${HOME}/Hyprshot"
        else
          log_warning "Failed to clone Hyprshot"
        fi
        break
        ;;
      "Manual install (show instructions)")
        cat << 'HYPRSHOT_INSTRUCTIONS'

Manual Hyprshot Installation:
1. Clone: git clone https://github.com/Gustash/hyprshot.git ~/Hyprshot
2. Make executable: chmod +x ~/Hyprshot/hyprshot
3. Create symlink: mkdir -p ~/.local/bin && ln -s ~/Hyprshot/hyprshot ~/.local/bin/hyprshot
4. Verify: hyprshot --help

HYPRSHOT_INSTRUCTIONS
        break
        ;;
      "Skip")
        log_info "Hyprshot installation skipped"
        break
        ;;
      *)
        log_warning "Invalid option"
        ;;
    esac
  done
}

# ============================================================================
# INSTALLATION SUMMARY
# ============================================================================

show_install_summary() {
  log_section "Installation Complete"

  cat << EOF
╔════════════════════════════════════════════════════════════╗
║       LinuxMintHyprlandConfig Installation Summary         ║
╚════════════════════════════════════════════════════════════╝

✓ Packages Installed/Verified: $PACKAGES_INSTALLED
✓ Configurations Backed Up:    $CONFIGS_BACKED_UP
✓ Symlinks Created:            $SYMLINKS_CREATED

Backup Location:               $BACKUP_PATH

IMPORTANT NEXT STEPS:
────────────────────────────────────────────────────────────

1. ADD i2c GROUP (if prompted):
   You were added to the i2c group for brightness control.
   ⚠ You must LOGOUT and LOGIN for changes to take effect.

2. VERIFY ENVIRONMENT:
   • In a new terminal: echo \$PATH
   • Should see: /home/[user]/.local/bin
   • Test command: which brightnessCheck

3. LOG OUT & LOGIN:
   • Select Hyprland from login session menu
   • Or press Alt+F2 to reload Hyprland

4. UNINSTALLATION:
   ${REPO_ROOT}/uninstall.sh

NEXT STEPS:
────────────────────────────────────────────────────────────
• Reload your shell: source ~/.bashrc
• Logout and login for full environment setup
• Log in to Hyprland desktop environment
• Test brightness control: brightnessCheck +
• Take a screenshot: hyprshot --help

EOF
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  log_section "LinuxMintHyprlandConfig Installation"

  echo "This script will:"
  echo "  • Install system packages (requires sudo)"
  echo "  • Create symlinks in ~/.local/bin (user-local, no sudo)"
  echo "  • Create symlinks in ~/.config (user-local, no sudo)"
  echo "  • Configure .bashrc with environment variables"
  echo "  • Apply GTK theme"
  echo "  • Back up existing configurations"
  echo ""

  read -p "Continue with installation? (y/n) [n]: " -r continue_install
  continue_install=${continue_install:-n}

  if [[ ! $continue_install =~ ^[Yy]$ ]]; then
    log_warning "Installation cancelled"
    exit 0
  fi

  check_environment
  install_system_packages
  configure_permissions
  backup_existing_configs
  create_all_symlinks
  configure_bashrc
  apply_gtk_theme
  install_obsidian_theme
  install_hyprshot

  show_install_summary

  log_success "Installation completed successfully!"
}

main "$@"
