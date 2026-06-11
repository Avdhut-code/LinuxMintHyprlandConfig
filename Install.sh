#!/bin/bash
# LinuxMintHyprlandConfig - Installation Script
# Automates installation of Hyprland dotfiles with backup & restoration

set -euo pipefail # if something fails exit 

# Color output helpers
RED='\033;0;31m'
GREEN='\033;0;32m'
YELLOW='\033;1;33m'
BLUE='\033;0;34m'
NC='\033[0m' # end character for color ascii

# Script metadata & Permanent Paths
ORIGINAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.local/share/LinuxMintHyprlandConfig"
BACKUP_DIR="${TARGET_DIR}/OriginalConfigFolders"
BACKUP_TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_PATH="${BACKUP_DIR}/backup_${BACKUP_TIMESTAMP}"
MANIFEST_FILE="${TARGET_DIR}/uninstall-manifest.txt"

# Counters
SYMLINKS_CREATED=0
CONFIGS_BACKED_UP=0
PACKAGES_INSTALLED=0

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

check_environment() {
  log_section "Pre-Installation Checks"

  if [ ! -f "${ORIGINAL_DIR}/README.md" ] || [ ! -d "${ORIGINAL_DIR}/config" ]; then
    exit_with_error "Script must be run from repository root directory"
  fi

  log_success "Running from correct directory: ${ORIGINAL_DIR}"

  if ! grep -q "^ID=.*debian\|^ID=linuxmint" /etc/os-release 2>/dev/null; then
    exit_with_error "This script only supports Debian-based systems (Linux Mint, Ubuntu, etc.)"
  fi

  log_success "System is Debian-based"
}

install_system_packages() {
  log_section "System Package Installation"
 
  log_info "Updating package manager..."
  sudo apt update -qq >/dev/null 2>&1

  log_info "Installing core packages..."
  
  sudo apt install -y \
    wofi \
    libnotify \
    swaync \
    swaybg \
    gsettings-desktop-schemas \
    dconf-cli \
    amixer \
    playerctl \
    gnome-terminal \
    nemo \
    xed \
    git \
    ddcutil \
    btop \
    htop \
    evince \
    pavucontrol \
    gnome-calendar \
    mpv \
    obsidian
 
  log_success "Core packages installed/verified"
  PACKAGES_INSTALLED=20
}

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

relocate_repository() {
  log_section "Relocating Dotfiles Suite"
  
  if [ "$ORIGINAL_DIR" == "$TARGET_DIR" ]; then
    log_info "Already running from target directory. Skipping copy."
    return
  fi

  log_info "Moving suite to permanent home: $TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  
  # Copy all visible files and directories
  cp -r "$ORIGINAL_DIR"/* "$TARGET_DIR/"
  
  # Copy hidden files safely
  cp -r "$ORIGINAL_DIR"/.[^.]* "$TARGET_DIR/" 2>/dev/null || true
  
  log_success "Dotfiles centralized. All future operations will use $TARGET_DIR"
}

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

create_all_symlinks() {
  log_section "Creating Symlinks"

  mkdir -p "${HOME}/.config"

  # Config directories
  log_info "Config directories:"
  ln -sfn "${TARGET_DIR}/config/hypr" "${HOME}/.config/hypr" && ((SYMLINKS_CREATED++))
  ln -sfn "${TARGET_DIR}/config/waybar" "${HOME}/.config/waybar" && ((SYMLINKS_CREATED++))
  ln -sfn "${TARGET_DIR}/config/wofi" "${HOME}/.config/wofi" && ((SYMLINKS_CREATED++))
  ln -sfn "${TARGET_DIR}/config/btop" "${HOME}/.config/btop" && ((SYMLINKS_CREATED++))

  # Scripts to ~/.local/bin
  log_info "Scripts to ~/.local/bin:"
  mkdir -p "${HOME}/.local/bin"
  if [ -d "${TARGET_DIR}/bin" ]; then
    for script in "${TARGET_DIR}"/bin/*.sh; do
      [ -e "$script" ] || continue
      script_name=$(basename "$script" .sh)
      ln -sfn "$script" "${HOME}/.local/bin/$script_name" && ((SYMLINKS_CREATED++))
    done
  fi

  # GTK Theme
  log_info "GTK theme:"
  mkdir -p "${HOME}/.themes"
  ln -sfn "${TARGET_DIR}/theme/gtkThemes/Graphite-Dark" "${HOME}/.themes/Graphite-Dark" && ((SYMLINKS_CREATED++))
  
  log_success "Created $SYMLINKS_CREATED symlink(s)"
}

configure_bashrc() {
  log_section "Configuring .bashrc"

  if [ ! -f "${HOME}/.bashrc" ]; then
    exit_with_error "~/.bashrc not found"
  fi

  if grep -q "# === HYPRLAND CONFIG START ===" "${HOME}/.bashrc"; then
    log_info "Hyprland configuration already in .bashrc (skipping)"
    return
  fi

  if [ -f "$ORIGINAL_DIR/bashappend.txt" ]; then
    cat "$ORIGINAL_DIR/bashappend.txt" >> "${HOME}/.bashrc" 
    log_success ".bashrc configured with PATH export and environment variables"
  else
    log_warning "bashappend.txt not found, skipping .bashrc modification"
  fi
}

apply_gtk_theme() {
  log_section "Applying GTK Theme"

  if command -v gsettings &>/dev/null; then
    log_info "Setting GTK theme to Graphite-Dark..."
    gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Dark" 2>/dev/null && \
      log_success "GNOME theme set" || log_warning "Could not set GNOME theme"
  else
    log_warning "gsettings not available, theme must be applied manually"
  fi
}

install_hyprshot() {
  log_section "Hyprshot Installation (Optional)"

  # Check if running interactively
  if [ ! -t 0 ]; then
    log_info "Non-interactive shell detected, skipping Hyprshot setup prompt."
    return
  fi

  PS3="Select Hyprshot installation method: "
  options=("Auto install from GitHub" "Manual install (show instructions)" "Skip")
  select opt in "${options[@]}"; do
    case $opt in
      "Auto install from GitHub")
        log_info "Cloning Hyprshot..."
        mkdir -p "${TARGET_DIR}"
        if git clone https://github.com/Gustash/hyprshot.git "${HOME}/Hyprshot" 2>/dev/null; then
          chmod +x "${HOME}/Hyprshot/hyprshot"
          mkdir -p "${HOME}/.local/bin"
          ln -sfn "${HOME}/Hyprshot/hyprshot" "${HOME}/.local/bin/hyprshot"
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

show_install_summary() {
  log_section "Installation Complete"

  cat << EOF
╔════════════════════════════════════════════════════════════╗
║       LinuxMintHyprlandConfig Installation Summary         ║
╚════════════════════════════════════════════════════════════╝

✓ Suite Centralized To:        $TARGET_DIR
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

4. TEST FUNCTIONALITY:
   • Brightness control: brightnessCheck +
   • Take a screenshot: hyprshot --help

5. BASHRC RELOADS
   • Reload your shell: source ~/.bashrc

EOF
}

main() {
  log_section "LinuxMintHyprlandConfig Installation"

  echo "This script will:"
  echo "  • Relocate suite to ~/.local/share/LinuxMintHyprlandConfig"
  echo "  • Install system packages (requires sudo)"
  echo "  • Create symlinks in ~/.local/bin (user-local, no sudo)"
  echo "  • Create symlinks in ~/.config (user-local, no sudo)"
  echo "  • Configure .bashrc with safe environment variables"
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
  relocate_repository
  configure_permissions
  backup_existing_configs
  create_all_symlinks
  configure_bashrc
  apply_gtk_theme
  install_hyprshot

  show_install_summary

  log_success "Installation completed successfully!"
}

main "$@"