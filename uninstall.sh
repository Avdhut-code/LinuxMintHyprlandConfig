#!/bin/bash
# LinuxMintHyprlandConfig - Uninstallation Script
# This script reverses all changes made by install.sh

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
MANIFEST_FILE="${REPO_ROOT}/uninstall-manifest.txt"

# Counters
SYMLINKS_REMOVED=0
CONFIGS_RESTORED=0
BASHRC_CLEANED=0

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
  log_section "Pre-Uninstallation Checks"

  if [ ! -f "${REPO_ROOT}/README.md" ] || [ ! -d "${REPO_ROOT}/config" ]; then
    exit_with_error "Script must be run from repository root directory"
  fi

  log_success "Running from correct directory: ${REPO_ROOT}"

  if [ ! -f "$MANIFEST_FILE" ]; then
    exit_with_error "No uninstall manifest found at $MANIFEST_FILE. Has install.sh been run?"
  fi

  log_success "Found uninstall manifest"

  if [ ! -d "$BACKUP_DIR" ]; then
    log_warning "Backup directory not found. Configuration restore may not be possible."
  fi
}

# ============================================================================
# BACKUP SELECTION
# ============================================================================

select_backup() {
  log_section "Backup Selection"

  if [ ! -d "$BACKUP_DIR" ]; then
    log_warning "No backup directory found"
    return
  fi

  local backups=($(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" | sort -r))

  if [ ${#backups[@]} -eq 0 ]; then
    log_warning "No backups found in $BACKUP_DIR"
    return
  fi

  log_info "Found ${#backups[@]} backup(s):"
  for i in "${!backups[@]}"; do
    echo "  $((i+1))) ${backups[$i]##*/}"
  done

  read -p "Select backup to restore from (or 0 to skip): " -r backup_choice
  backup_choice=${backup_choice:-0}

  if [ "$backup_choice" -ge 1 ] && [ "$backup_choice" -le ${#backups[@]} ]; then
    SELECTED_BACKUP="${backups[$((backup_choice-1))]}"
    log_success "Selected backup: $SELECTED_BACKUP"
  else
    log_info "No backup selected for restoration"
    SELECTED_BACKUP=""
  fi
}

# ============================================================================
# SYMLINK REMOVAL
# ============================================================================

remove_symlinks() {
  log_section "Removing Symlinks"

  if [ ! -f "$MANIFEST_FILE" ]; then
    log_warning "No manifest file found"
    return
  fi

  local manifest_lines=0
  while IFS='|' read -r type target source; do
    [ "$type" = "SYMLINK" ] || [ "$type" = "SCRIPT" ] || [ "$type" = "HYPRSHOT" ] || continue

    if [ -L "$target" ]; then
      rm "$target"
      log_success "Removed symlink: $target"
      ((SYMLINKS_REMOVED++))
    elif [ -e "$target" ] && [ ! -d "$target" ]; then
      log_warning "Path exists but is not a symlink (skipped): $target"
    fi

    ((manifest_lines++))
  done < "$MANIFEST_FILE"

  if [ $SYMLINKS_REMOVED -gt 0 ]; then
    log_success "Removed $SYMLINKS_REMOVED symlink(s)"
  else
    log_info "No symlinks to remove"
  fi
}

# ============================================================================
# CONFIGURATION RESTORATION
# ============================================================================

restore_configurations() {
  log_section "Restoring Original Configurations"

  if [ -z "${SELECTED_BACKUP:-}" ] || [ ! -d "$SELECTED_BACKUP" ]; then
    log_warning "No backup available for restoration"
    return
  fi

  local backup_manifest="${SELECTED_BACKUP}/BACKUP_MANIFEST.txt"

  if [ ! -f "$backup_manifest" ]; then
    log_warning "No backup manifest found in $SELECTED_BACKUP"
    return
  fi

  while IFS='|' read -r backup_type original_path backup_path; do
    [ -z "$backup_type" ] && continue
    [ "$backup_type" = "DIR" ] || [ "$backup_type" = "FILE" ] || continue

    if [ ! -e "$backup_path" ]; then
      log_warning "Backup file not found: $backup_path"
      continue
    fi

    mkdir -p "$(dirname "$original_path")"

    if [ -e "$original_path" ]; then
      log_warning "Original path exists, backing up current: $original_path"
      mv "$original_path" "${original_path}.tmp"
    fi

    cp -r "$backup_path" "$original_path"
    log_success "Restored: $original_path"
    ((CONFIGS_RESTORED++))
  done < "$backup_manifest"

  if [ $CONFIGS_RESTORED -gt 0 ]; then
    log_success "Restored $CONFIGS_RESTORED configuration(s)"
  fi
}

# ============================================================================
# BASHRC CLEANUP
# ============================================================================

clean_bashrc() {
  log_section "Cleaning .bashrc"

  if [ ! -f "${HOME}/.bashrc" ]; then
    log_info "No .bashrc found"
    return
  fi

  if ! grep -q "# === HYPRLAND CONFIG START ===" "${HOME}/.bashrc"; then
    log_info "No Hyprland configuration found in .bashrc"
    return
  fi

  log_info "Removing Hyprland configuration from .bashrc..."

  # Remove marked section
  sed -i '/# === HYPRLAND CONFIG START ===/,/# === HYPRLAND CONFIG END ===/d' "${HOME}/.bashrc"

  log_success ".bashrc cleaned"
  ((BASHRC_CLEANED++))

  if [ -n "${SELECTED_BACKUP:-}" ] && [ -f "${SELECTED_BACKUP}/.bashrc" ]; then
    log_info "Original .bashrc available in backup"
    read -p "Restore original .bashrc? (y/n) [n]: " -r restore_bashrc
    restore_bashrc=${restore_bashrc:-n}

    if [[ $restore_bashrc =~ ^[Yy]$ ]]; then
      cp "${SELECTED_BACKUP}/.bashrc" "${HOME}/.bashrc"
      log_success "Original .bashrc restored"
    fi
  fi
}

# ============================================================================
# THEME CLEANUP
# ============================================================================

remove_themes() {
  log_section "Removing Themes"

  if [ -L "${HOME}/.themes/Graphite-Dark" ]; then
    rm "${HOME}/.themes/Graphite-Dark"
    log_success "Removed GTK theme symlink"
  fi

  # Revert GTK theme
  log_info "Reverting GTK theme settings..."

  gsettings reset org.cinnamon.desktop.interface gtk-theme 2>/dev/null && \
    log_success "Cinnamon theme reset" || true

  gsettings reset org.gnome.desktop.interface gtk-theme 2>/dev/null && \
    log_success "GNOME theme reset" || true

  # Remove Obsidian theme if present
  local obsidian_theme_paths=(
    "${HOME}/.local/share/obsidian/themes/pitchBlack"
    "${HOME}/snap/obsidian/common/.obsidian/themes/pitchBlack"
    "${HOME}/.config/obsidian/themes/pitchBlack"
  )

  for theme_path in "${obsidian_theme_paths[@]}"; do
    if [ -d "$theme_path" ]; then
      rm -rf "$theme_path"
      log_success "Removed Obsidian theme from: $theme_path"
    fi
  done
}

# ============================================================================
# OPTIONAL APPLICATION REMOVAL
# ============================================================================

prompt_remove_applications() {
  log_section "Optional Application Removal"

  read -p "Remove installed applications? (y/n) [n]: " -r remove_apps
  remove_apps=${remove_apps:-n}

  if [[ ! $remove_apps =~ ^[Yy]$ ]]; then
    log_info "Skipping application removal"
    return
  fi

  OPTIONAL_PACKAGES=(
    code
    obsidian
    mpv
    gnome-calendar
    pavucontrol
  )

  log_info "The following applications will be considered for removal:"
  for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
      echo "  • $pkg (installed)"
    fi
  done

  read -p "Continue with removal? (y/n) [n]: " -r confirm_removal
  confirm_removal=${confirm_removal:-n}

  if [[ ! $confirm_removal =~ ^[Yy]$ ]]; then
    log_info "Skipping application removal"
    return
  fi

  if ! sudo -v; then
    log_warning "Could not obtain sudo privileges, skipping application removal"
    return
  fi

  for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
      log_info "Removing $pkg..."
      sudo apt remove -y "$pkg" >/dev/null 2>&1 && log_success "Removed $pkg" || log_warning "Failed to remove $pkg"
    fi
  done
}

# ============================================================================
# CLEANUP & BACKUP MANAGEMENT
# ============================================================================

cleanup_installation() {
  log_section "Cleanup"

  # Remove manifest file
  if [ -f "$MANIFEST_FILE" ]; then
    rm "$MANIFEST_FILE"
    log_success "Removed installation manifest"
  fi

  # Offer to remove backup folder
  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    log_info "Backup folder contains:"
    find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" | while read -r backup; do
      echo "  • ${backup##*/}"
    done

    read -p "Remove all backups? (y/n) [n]: " -r remove_backups
    remove_backups=${remove_backups:-n}

    if [[ $remove_backups =~ ^[Yy]$ ]]; then
      rm -rf "$BACKUP_DIR"
      log_success "Removed backup folder: $BACKUP_DIR"
    else
      log_info "Keeping backup folder for safety"
    fi
  fi

  # Remove Hyprshot if installed
  if [ -f "${HOME}/.local/bin/hyprshot" ]; then
    read -p "Remove Hyprshot? (y/n) [n]: " -r remove_hyprshot
    remove_hyprshot=${remove_hyprshot:-n}

    if [[ $remove_hyprshot =~ ^[Yy]$ ]]; then
      rm "${HOME}/.local/bin/hyprshot"
      log_success "Removed Hyprshot symlink"

      if [ -d "${HOME}/Hyprshot" ]; then
        read -p "Remove Hyprshot source directory (~/Hyprshot)? (y/n) [n]: " -r remove_hyprshot_source
        remove_hyprshot_source=${remove_hyprshot_source:-n}

        if [[ $remove_hyprshot_source =~ ^[Yy]$ ]]; then
          rm -rf "${HOME}/Hyprshot"
          log_success "Removed Hyprshot source directory"
        fi
      fi
    fi
  fi
}

# ============================================================================
# UNINSTALLATION SUMMARY
# ============================================================================

show_uninstall_summary() {
  log_section "Uninstallation Complete"

  cat << EOF
╔════════════════════════════════════════════════════════════╗
║       LinuxMintHyprlandConfig Uninstallation Summary       ║
╚════════════════════════════════════════════════════════════╝

✓ Symlinks Removed:           $SYMLINKS_REMOVED
✓ Configurations Restored:    $CONFIGS_RESTORED
✓ Bashrc Cleaned:             $BASHRC_CLEANED

EOF

  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    cat << EOF
Backup Location:              $BACKUP_DIR
(Backups retained for safety)

EOF
  fi

  cat << EOF
NEXT STEPS:
────────────────────────────────────────────────────────────

1. Logout and login to apply all changes:
   • GTK theme will revert to default
   • .bashrc changes take effect in new terminals

2. Verify system state:
   • Check System Settings for default theme
   • Open new terminal to verify clean environment

3. If you need to reinstall:
   ${REPO_ROOT}/install.sh

EOF
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  log_section "LinuxMintHyprlandConfig Uninstallation"

  echo "This script will reverse all changes made by install.sh"
  echo ""
  echo "The following will be done:"
  echo "  • Remove all created symlinks"
  echo "  • Restore original configuration files"
  echo "  • Clean .bashrc modifications"
  echo "  • Revert theme settings"
  echo ""

  read -p "Continue? (y/n) [n]: " -r continue_uninstall
  continue_uninstall=${continue_uninstall:-n}

  if [[ ! $continue_uninstall =~ ^[Yy]$ ]]; then
    log_warning "Uninstallation cancelled"
    exit 0
  fi

  check_environment
  select_backup
  remove_symlinks
  restore_configurations
  clean_bashrc
  remove_themes
  prompt_remove_applications
  cleanup_installation

  show_uninstall_summary

  log_success "Uninstallation completed successfully!"
}

main "$@"
