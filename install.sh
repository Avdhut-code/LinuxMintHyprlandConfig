#!/bin/bash

set -euo pipefail # if something fails exit

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

ORIGINAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.local/share/LinuxMintHyprlandConfig"

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

checkIfDebian() {
	if [ ! -f "${ORIGINAL_DIR}/README.md" ] || [ ! -d "${ORIGINAL_DIR}/config" ]; then
		exit_with_error "Script must be run from repository root directory"
	fi

	log_success "Running from correct directory: ${ORIGINAL_DIR}"

	if ! grep -q "^ID=.*debian\|^ID=linuxmint" /etc/os-release 2>/dev/null; then
		exit_with_error "This script only supports Debian-based systems (Linux Mint, Ubuntu, etc.)"
	fi

	log_success "System is Debian-based"
}

installPackage(){
	log_info "Updating package manager..."

	sudo apt update 
	sudo apt install -y \
		git \
		ddcutil \
		btop \
		htop \
		libnotify-bin \    
		pavucontrol \
		wireplumber \      
		pipewire \
		# swaync \
		swaybg \
		playerctl \
		waybar \
		wofi \
		gnome-terminal \
		# gnome-calendar \
		evince \
		xed \
		nemo \
		mpv
	sudo apt autoremove -y
	sudo apt clean -y

	log_success "System packages installed successfully"
}

repoCopyToTarget() {
	log_info "Moving suite to permanent home: $TARGET_DIR"

	if [ "$ORIGINAL_DIR" = "$TARGET_DIR" ]; then
		log_info "Already in target directory, skipping copy."
		return
	fi

	mkdir -p "$TARGET_DIR"

	cp -r "$ORIGINAL_DIR"/* "$TARGET_DIR/"

	cp -r "$ORIGINAL_DIR"/.[^.]* "$TARGET_DIR/" 2>/dev/null || true

	log_success "Dotfiles centralized. All future operations will use $TARGET_DIR"
}

takePermissions() {
	log_info "Adding user to i2c group for DDC-CI brightness control..."

	if ! groups | grep -q i2c; then
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

	log_success "Permissions set for ~/.local/bin"
}

simlinkCreate() {
	mkdir -p "${HOME}/.config"

	log_info "Config directories:"
	ln -sfn "${TARGET_DIR}/config/hypr" 	"${HOME}/.config/"
	ln -sfn "${TARGET_DIR}/config/waybar" 	"${HOME}/.config/"
	ln -sfn "${TARGET_DIR}/config/wofi" 	"${HOME}/.config/"
	ln -sfn "${TARGET_DIR}/config/btop" 	"${HOME}/.config/"

	log_info "Scripts to ~/.local/bin:"

	mkdir -p "${HOME}/.local/bin"

	ln -sfn "${TARGET_DIR}/bin/brightnessCheck.sh"    "${HOME}/.local/bin/brightnessCheck"
	ln -sfn "${TARGET_DIR}/bin/codecho.sh"            "${HOME}/.local/bin/codecho"
	ln -sfn "${TARGET_DIR}/bin/custom-launch-btop.sh" "${HOME}/.local/bin/custom-launch-btop"
	ln -sfn "${TARGET_DIR}/bin/custom-open-link.sh"   "${HOME}/.local/bin/custom-open-link"
	ln -sfn "${TARGET_DIR}/bin/gnome-terExit.sh"      "${HOME}/.local/bin/gnome-terExit"
	ln -sfn "${TARGET_DIR}/bin/startup.sh"            "${HOME}/.local/bin/startup"
	ln -sfn "${TARGET_DIR}/bin/wofiDrawer.sh"         "${HOME}/.local/bin/wofiDrawer"

	log_info "Setting script permissions..."
	
	chmod +x "${TARGET_DIR}/bin/brightnessCheck.sh"
	chmod +x "${TARGET_DIR}/bin/codecho.sh"
	chmod +x "${TARGET_DIR}/bin/custom-launch-btop.sh"
	chmod +x "${TARGET_DIR}/bin/custom-open-link.sh"
	chmod +x "${TARGET_DIR}/bin/gnome-terExit.sh"
	chmod +x "${TARGET_DIR}/bin/startup.sh"
	chmod +x "${TARGET_DIR}/bin/wofiDrawer.sh"

	log_info "GTK theme:"

	mkdir -p "${HOME}/.themes"

	ln -sfn "${TARGET_DIR}/theme/gtkThemes/Graphite-Dark" "${HOME}/.themes/"

	log_success "Created symlink(s)"
}

bashAppend() {
	if [ ! -f "${HOME}/.bashrc" ]; then
		exit_with_error "~/.bashrc not found"
	fi

	if grep -q "# === hyprland config start ===" "${HOME}/.bashrc"; then
		log_info "hyprland configuration already in .bashrc (skipping)"
	return
	fi

	if [ -f "$ORIGINAL_DIR/bashAppend.txt" ]; then
		cat "$ORIGINAL_DIR/bashAppend.txt" >> "${HOME}/.bashrc"
		log_success ".bashrc configured with path export and environment variables"
	else
		log_warning "bashAppend.txt not found, skipping .bashrc modification"
	fi
}

themeApply() {
	if command -v gsettings &>/dev/null; then
		log_info "Setting GTK theme to Graphite-Dark..."
		gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Dark" 2>/dev/null && \
		log_success "GNOME theme set" || log_warning "Could not set GNOME theme"
	else
		log_warning "gsettings not available, theme must be applied manually"
	fi
}

hyprshotInstall() {
	if [ ! -t 0 ]; then
		log_info "Non-interactive shell detected, skipping."
		return
	fi

	echo "  [1] Auto install from GitHub"
	echo "  [2] Manual install (show instructions)"
	echo "  [3] Skip"
	read -rp "Select option [1/2/3]: " choice

	case "$choice" in
	1)
	log_info "Cloning Hyprshot..."
	if git clone https://github.com/Gustash/hyprshot.git "${HOME}/Hyprshot" 2>/dev/null; then
		chmod +x "${HOME}/Hyprshot/hyprshot"
		mkdir -p "${HOME}/.local/bin"
		ln -sfn "${HOME}/Hyprshot/hyprshot" "${HOME}/.local/bin/hyprshot"
		log_success "Hyprshot installed at: ${HOME}/Hyprshot"
	else
		log_warning "Failed to clone Hyprshot"
	fi
	;;
	2)
      	echo """
		Manual Hyprshot Installation:
			1. git clone https://github.com/Gustash/hyprshot.git ~/Hyprshot
			2. chmod +x ~/Hyprshot/hyprshot
			3. mkdir -p ~/.local/bin && ln -s ~/Hyprshot/hyprshot ~/.local/bin/hyprshot
			4. hyprshot --help 
	"""
      	;;
    	3|*)
      		log_info "Hyprshot installation skipped"
      	;;
  	esac
}

walkInstall() {
	if command -v walk &>/dev/null; then
		log_success "Walk is already installed, skipping."
		return
	fi

	log_info "Cloning walk..."   #### ADD THE CASE OPTIONAL INSATALL LIKE HYPRSHOT

	echo "  [1] Auto install from GitHub"
	echo "  [2] Manual install (show instructions)"
	echo "  [3] Skip"
	read -rp "Select option [1/2/3]: " walkChoice
	
	case "$walkChoice" in
	1)
	if git clone https://github.com/antonmedv/walk.git "${HOME}/walk" 2>/dev/null; then
		log_info "Running walk install script..."
		if bash "${HOME}/walk/install.sh"; then
			log_success "Walk installed successfully"
		else
		l	og_warning "Walk install script failed"
		fi
	else
		log_warning "Failed to clone walk"
	fi
	;;
	2)
      	echo """
		Manual Walk Installation:
			1. git clone https://github.com/antonmedv/walk.git ~/walk
			2. chmod +x ~/walk/install.sh
			3. bash ~/walk/install.sh
	"""
	;;
	3|*)
		log_info "Walk installation skipped"
	;;
	esac

}

installObsidian() {
	# log_info "Installing Obsidian..."

	echo "  [1] Auto install from GitHub"
	echo "  [2] Manual install (show instructions)"
	echo "  [3] Skip"
	read -rp "Select option [1/2/3]: " obsidianChoice
	
	case "$obsidianChoice" in
	1)
	log_info "Installing latest version..."
	
	local version

	version=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
		| grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')

	local deb_url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian_${version}_amd64.deb"
	
	local deb_path="/tmp/obsidian_${version}.deb"

	if curl -L "$deb_url" -o "$deb_path"; then
		sudo apt install -y "$deb_path"
		rm "$deb_path"
		log_success "Obsidian ${version} installed"
		log_info "Now you can add the obsidian dark theme to your vault"
	else
		log_warning "Failed to download Obsidian, install it manually from https://obsidian.md"
	fi
	;;
	2)
      	echo """
		Manual Obsidian Installation:
			1. got to https://obsidian.md/download
			2. download the appropriate package for you system
			3. got to the download directory and run "sudo apt install ./obsidian_*.deb"
			4. install it with "sudo apt install ./path/to/obsidian_*.deb"
			5. remove the .deb file after installation with "rm ./path/to/obsidian_*.deb"
			6. Now you can add the obsidian dark theme to your vault
	"""
	
	;;
	3|*)
		log_info "Obsidian installation skipped"
	;;
	esac
}

main() {
	log_section "LinuxMintHyprlandConfig Installation"

	echo "This script will:"
	echo "  • Relocate suite to ~/.local/share/LinuxMintHyprlandConfig"
	echo "  • Install system packages (requires sudo)"
	echo "  • Create symlinks in ~/.local/bin (user-local, no sudo)"
	echo "  • Create symlinks in ~/.config (user-local, no sudo)"
	echo "  • Append to .bashrc with safe environment variables"
	echo "  • Apply GTK theme with gesttings"
	echo ""

	read -p "Continue with installation? (y/n) [n]: " -r continue_install
	continue_install=${continue_install:-n}

	if [[ ! $continue_install =~ ^[Yy]$ ]]; then
		log_warning "Installation cancelled"
		exit 0
	fi

  	log_section "Pre-Installation Checks"
	checkIfDebian

	log_section "System Package Installation"
	installPackage

	log_section "Relocating Dotfiles Suite"
	repoCopyToTarget

	log_section "Permissions & Configuration"
	takePermissions

	log_section "Creating Symlinks"
	simlinkCreate

	log_section "configuring .bashrc"
	bashAppend

	log_section "Applying GTK Theme"
	themeApply

	log_section "Hyprshot Installation (Optional)"
	hyprshotInstall

	log_section "Walk Installation (Optional)"
	walkInstall

	log_section "Obsidian Installation (Optional)"
	installObsidian

	log_section " Install Done."

	log_success "Installation completed successfully!"
}

main "$@"