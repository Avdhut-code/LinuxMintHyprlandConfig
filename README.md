# LinuxMintHyprlandConfig

This an custom .dotfile repo for my personal mint-hyprland setup. So its dark, minimal, dosent follow a structure , just stuff randomly everywhere.

---

# Warning

this is only for `Debian` based [mint to be specfic] systems with it having `Hyprland`

---

<!-- # Installing Hyperland

if you dont have hyprland, here is a guild to how to do it
 - all the steps
 - with precautions
 - steps
 - waring about how the hyprland is not stable on debian systems
 - use of hyprctl with its wiki refrence  -->

# Installing Hyprland on Linux Mint

<details>
<summary><b>Click to expand/collapse installation steps</b></summary>

This guide outlines how to install the Hyprland Wayland compositor on Linux Mint using an automated installation script.

> [!NOTE]
> **Credits & Respect to the Author:** This setup utilizes the incredible work, automation scripts, and configurations maintained by **JaKooLit**. Please consider starring the original repository to support the developer.
>
> - **Original Repository:** [JaKooLit/Ubuntu-Hyprland](https://github.com/JaKooLit/Ubuntu-Hyprland)

---

## Step 1: Prepare System Dependencies

Update your current package lists and install core utilities required for cloning and building the configurations.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git make cmake -y
```

## Step 2: Identify Your Mint Version Base

Linux Mint releases are built on top of specific Ubuntu LTS bases. You must target the branch matching your Mint version:

- **Linux Mint 22** is based on **Ubuntu 24.04**
- **Linux Mint 21 (21.1, 21.2, 21.3)** is based on **Ubuntu 22.04**

## Step 3: Clone the Specific Repository Branch

Clear out any previous empty clones and pull the active installer files targeting your version.

### For Linux Mint 22:

```bash
cd ~
rm -rf Ubuntu-Hyprland
git clone -b 24.04 --depth 1 https://github.com.git
```

### For Linux Mint 21:

```bash
cd ~
rm -rf Ubuntu-Hyprland
git clone -b 22.04 --depth 1 https://github.com.git
```

## Step 4: Run the Installer Script

Navigate into the newly cloned project directory, make the installer executable, and run it.

```bash
cd Ubuntu-Hyprland
chmod +x install.sh
./install.sh
```

## Step 5: Follow Interactive Prompts & Reboot

The text-based setup menu will guide you through the process:

1. Enter your `sudo` password when requested to install packages.
2. Choose options corresponding to your hardware (especially if utilizing an **Nvidia** GPU).
3. Select additional features like Waybar or custom GTK themes.
4. Once completed, reboot your system.

## Step 6: Log Into Hyprland

1. On your Linux Mint login screen, select your username.
2. Click the desktop environment/session icon (usually a small gear or emblem near the password field).
3. Select **Hyprland** from the list.
4. Enter your password and log in.

---

### Additional Resources

- **Video Guide Walkthrough:** [How to Install Hyprland on Ubuntu + Linux Mint + Pop Os](https://youtube.com)

</details>

---

# Theme Installation Steps

This section covers the installation of themes included in this dotfiles repository.

## Prerequisites

Before installing themes, ensure the following tools are installed:

```bash
sudo apt install gsettings-desktop-schemas dconf-cli -y
```

## Automatic Installation via `install.sh`

The easiest way to install all components (configs, tools, and themes) is to run the provided installation script:

```bash
cd ~/LinuxMintHyprlandConfig
chmod +x install.sh
./install.sh
```

This script will:
1. ✅ Backup existing configurations to `OriginalConfigFolders/`
2. ✅ Create symlinks for all configs → `~/.config/`
3. ✅ Create symlinks for all tools → `~/.local/bin/`
4. ✅ Install GTK theme → `~/.themes/`
5. ✅ Set GTK theme as system-wide default via `gsettings`
6. ✅ Optionally install Obsidian theme (with user prompt)

## Manual GTK Theme Installation

If you only want to install the **Graphite-Dark** GTK theme manually:

### Step 1: Copy Theme to System Directory

```bash
mkdir -p ~/.themes
cp -r ./theme/gtkThemes/Graphite-Dark ~/.themes/
```

### Step 2: Set as System Theme (Linux Mint GUI)

**Via Settings:**
1. Open **System Settings** → **Appearance** → **Themes**
2. Select **Graphite-Dark** from the GTK+ Theme dropdown
3. Apply changes

**Via Command Line (gsettings):**

```bash
gsettings set org.cinnamon.desktop.interface gtk-theme "Graphite-Dark"
gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Dark"
```

## Manual Obsidian Theme Installation

The repository includes a **Pitch Black** theme for Obsidian. To install it manually:

### Step 1: Locate Your Obsidian Vault

Find your Obsidian vault directory. Default locations:

- **Linux:** `~/.local/share/obsidian/`
- **Snap:** `~/snap/obsidian/common/.obsidian/`

### Step 2: Copy Theme to Obsidian Themes Folder

```bash
# Replace <vault-path> with your actual Obsidian vault location
cp -r ./theme/Obsidian/pitchBlack "<vault-path>/.obsidian/themes/"
```

### Step 3: Activate Theme in Obsidian

1. Open Obsidian
2. Go to **Settings** → **Appearance** → **Themes**
3. Select **pitchBlack** from the dropdown
4. Apply

## Troubleshooting

### GTK Theme Not Applying

**Problem:** Theme appears in Settings but doesn't apply globally.

**Solution:**
```bash
# Clear cache and reapply
gsettings reset org.cinnamon.desktop.interface gtk-theme
gsettings set org.cinnamon.desktop.interface gtk-theme "Graphite-Dark"

# Then log out and log back in
```

### Obsidian Theme Not Appearing

**Problem:** Theme folder copied but doesn't show up in Obsidian.

**Solutions:**
1. Ensure the theme folder is in the correct location:
   ```bash
   ls -la "~/.obsidian/themes/pitchBlack/"
   ```
2. Restart Obsidian
3. Check that `manifest.json` exists in the theme folder:
   ```bash
   cat "~/.obsidian/themes/pitchBlack/manifest.json"
   ```

### Permission Denied When Setting Theme

**Problem:** Getting permission errors when running `gsettings` or `install.sh`.

**Solution:**
```bash
# Ensure you're not running as root
# Sudo is only needed for package installation, not for symlinks
```

## Reverting Themes

To revert to the original themes after installation:

### Revert GTK Theme

```bash
gsettings reset org.cinnamon.desktop.interface gtk-theme
```

### Uninstall All Components (Tools, Configs, Themes)

```bash
./uninstall.sh
```

This will:
- Remove all symlinks
- Restore original configurations from backups
- Restore original GTK theme settings

---

# Preview Images

1.![First preview Image, with some level of show casing of this system.](PreviewImage.png)

---

2.![Second preview Image, with showing the themeing of the editor [xed] and file manger [nemo].](PreviewImage2.png)

---

3.![Simple preview image showing nothing basic layout.](PreviewImage3.png)

---

# Wallpaper

<details>
  <summary>Wallpaper 1 - Full Blank Background.</summary>
  <br>
  <img src="wallpaper/wall1.png" alt="Wallpaper 1" width="100%">
</details>

<details>
  <summary>Wallpaper 2 - Dark Ocean Current (ig).</summary>
  <br>
  <img src="wallpaper/wall2.png" alt="Wallpaper 2" width="100%">
</details>

<details>
  <summary>Wallpaper 3 - Classic Nokia Handshake.</summary>
  <br>
  <img src="wallpaper/wall3.png" alt="Wallpaper 3" width="100%">
</details>

<details>
  <summary>Wallpaper 4 - Solo Rai Ayanamai.</summary>
  <br>
  <img src="wallpaper/wall4.png" alt="Wallpaper 4" width="100%">
</details>

<details>
  <summary>Wallpaper 5 - Rai and Asuka Manga Version.</summary>
  <br>
  <img src="wallpaper/wall5.png" alt="Wallpaper 5" width="100%">
</details>
__________________________________________________________________________________________

# Repository Structure Overview

This dotfiles repository follows a **centralized configuration management** approach where all Hyprland, application configs, themes, and custom tools are managed from a single source directory. Using symlinks, all files are linked to their appropriate user-specific locations without duplicating or moving the originals.

## Directory Layout

```
LinuxMintHyprlandConfig/
├── .bashrc                           # Shell configuration (→ ~/.bashrc)
├── bin/                              # Custom executable scripts (→ ~/.local/bin/)
│   ├── brightnessCheck.sh           # Brightness level checker (uses ddcutil)
│   ├── startup.sh                   # Hyprland startup script
│   ├── wofiDrawer.sh                # Wofi app launcher integration
│   ├── custom-launch-btop.sh        # Custom btop launcher
│   ├── custom-open-link.sh          # Web link opener
│   ├── gnome-terExit.sh             # Terminal exit handler
│   └── codecho.sh                   # Code clipboard utility
├── config/                           # Application configurations (→ ~/.config/)
│   ├── hypr/                        # Hyprland Wayland compositor config
│   │   ├── hyprland.conf            # Main compositor settings
│   │   ├── hypridle.conf            # Idle behavior & screen lock
│   │   ├── hyprlock.conf            # Screen lock configuration
│   │   ├── webappsbinds.conf        # Web app launcher keybindings
│   │   └── workspace.conf           # Workspace & monitor setup
│   ├── waybar/                      # Status bar (top panel) config
│   │   ├── config.jsonc
│   │   └── style.css
│   ├── wofi/                        # App launcher config
│   │   ├── config
│   │   ├── style.css
│   │   └── SearchBarStyle.css
│   └── btop/                        # System monitor theme
│       ├── btop.conf
│       └── theme/
├── theme/                            # Theming files
│   ├── gtkThemes/                   # GTK themes
│   │   └── Graphite-Dark/           # Dark GTK theme (→ ~/.themes/)
│   └── Obsidian/                    # Obsidian vault themes
│       └── pitchBlack/              # Pitch Black Obsidian theme (optional)
├── icon/                            # App launcher icons
│   ├── chatgpt.png
│   ├── claude.png
│   ├── google-*.png
│   └── ... (web app icons)
├── wallpaper/                       # Desktop wallpapers
│   ├── wall1.png
│   ├── wall2.png
│   └── ... (5 total wallpapers)
├── install.sh                       # Installation script (creates symlinks & backups)
├── uninstall.sh                     # Uninstallation script (removes symlinks & restores backups)
├── OriginalConfigFolders/           # Backup folder for original configs (auto-populated)
├── tools.conf                       # Documentation of required system tools
├── README.md                        # This file
└── PreviewImage*.png                # Screenshot previews
```

## Configuration Interconnections

```
┌─────────────────────────────────────────────────────────────────┐
│                      Core Components                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  .bashrc (Shell)                                                 │
│  ├─ Loads environment variables for system tools                │
│  ├─ Defines aliases & custom functions                          │
│  ├─ Sets BRIGHTNESS for brightness monitor                      │
│  └─ Sets CURRENT_WALLPAPER path                                 │
│                                                                  │
│  config/hypr/ (Hyprland Compositor)                              │
│  ├─ hyprland.conf → Calls bin/startup.sh (exec-once)            │
│  ├─ Binds keybinds to wofiDrawer.sh                             │
│  ├─ Configures hypridle.conf for idle behavior                  │
│  └─ References theme colors & icons from icon/ folder           │
│                                                                  │
│  config/waybar/ (Status Bar)                                     │
│  ├─ Displays system info from btop                              │
│  ├─ Integrates with Hyprland workspaces                         │
│  └─ Applies Graphite-Dark GTK theme styling                     │
│                                                                  │
│  bin/ (Utility Scripts)                                          │
│  ├─ Called by hyprland.conf keybinds                            │
│  ├─ Symlinked to ~/.local/bin/ for user-wide access             │
│  └─ Examples: brightness control, app launcher integration      │
│                                                                  │
│  theme/ (Visual Consistency)                                     │
│  ├─ GTK theme applied to GTK apps via gsettings                 │
│  └─ Obsidian theme optional, installed to Obsidian vault        │
│                                                                  │
│  icon/ & wallpaper/ (Resources)                                  │
│  ├─ Icons referenced in webappsbinds.conf                       │
│  └─ Wallpapers selected in .bashrc                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---


---

# Installation

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/LinuxMintHyprlandConfig.git
cd LinuxMintHyprlandConfig

# 2. Run the installation script
chmod +x install.sh
./install.sh

# 3. Follow the interactive prompts
# - Confirm backup of existing configs
# - Optionally install Obsidian theme
```

## What Gets Installed

| Component | Source | Target | Notes |
|-----------|--------|--------|-------|
| **Hyprland Config** | `config/hypr/` | `~/.config/hypr/` | Wayland compositor configuration |
| **Waybar** | `config/waybar/` | `~/.config/waybar/` | Status bar configuration |
| **Wofi** | `config/wofi/` | `~/.config/wofi/` | App launcher configuration |
| **Btop** | `config/btop/` | `~/.config/btop/` | System monitor theme |
| **Custom Tools** | `bin/` | `~/.local/bin/` | Scripts like brightness, wofi drawer, etc. |
| **Bash Config** | `.bashrc` | `~/.bashrc` | Shell aliases and environment variables |
| **GTK Theme** | `theme/gtkThemes/Graphite-Dark/` | `~/.themes/` | Dark GTK+ theme (automatically set) |
| **Obsidian Theme** | `theme/Obsidian/pitchBlack/` | `~/.config/obsidian/themes/` | Optional theme for Obsidian vault |

## Uninstallation

To remove all installations and restore original configurations:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

This will:
- Remove all symlinks
- Restore backed-up original configurations from `OriginalConfigFolders/`
- Restore original GTK theme settings

---

# Hyprshot Installation & Setup

**Hyprshot** is a screenshot utility for Hyprland that captures screenshots in multiple modes (output, window, region). It's integrated into this dotfile setup via the following keybindings:

```
PRINT              → Capture current output/monitor
Super + PRINT      → Capture current window
Shift + PRINT      → Capture region (drag to select)
```

## Installation

### Automatic Installation (Recommended)

During `./install.sh`, you will be prompted:

```
Hyprshot is a screenshot utility for Hyprland.

Options:
  1) Auto install (clone & build from GitHub)
  2) Manual install (show instructions, you install)
  0) Skip installation
```

Select option **1** to automatically:
- Clone from GitHub
- Set executable permissions
- Create symlink to `~/.local/bin/hyprshot`
- Verify installation

### Manual Installation

If you prefer to install Hyprshot manually, or if auto-installation fails:

#### Step 1: Clone Repository

```bash
git clone https://github.com/Gustash/hyprshot.git ~/Hyprshot
```

#### Step 2: Set Executable

```bash
chmod +x ~/Hyprshot/hyprshot
```

#### Step 3: Create Symlink

```bash
mkdir -p ~/.local/bin
ln -s ~/Hyprshot/hyprshot ~/.local/bin/hyprshot
```

#### Step 4: Ensure ~/.local/bin in PATH (if needed)

Add this to your `~/.bashrc` if `hyprshot` command is not found:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:

```bash
source ~/.bashrc
```

#### Step 5: Verify Installation

```bash
hyprshot --help
```

You should see the help output with usage instructions.

## Usage

### Command Line

```bash
# Capture current output (monitor/screen)
hyprshot -m output

# Capture active window
hyprshot -m window

# Capture region (drag to select)
hyprshot -m region
```

### Via Hyprland Keybindings

All three modes are available via keybindings (see `config/hypr/hyprland.conf` lines 186-188):

| Keybinding | Action |
|---|---|
| `PRINT` | Capture output |
| `Super + PRINT` | Capture window |
| `Shift + PRINT` | Capture region |

### Output Location

Screenshots are saved to:

```
~/Pictures/Screenshots/  (default location, Hyprshot creates if missing)
```

Or use `hyprshot` with the `-o` flag to specify output:

```bash
hyprshot -m region -o ~/custom-screenshot.png
```

## Troubleshooting

### Hyprshot command not found

**Problem:** After installation, `hyprshot` command not found in terminal.

**Solution:**
1. Verify installation: `ls -l ~/.local/bin/hyprshot`
2. Verify PATH: `echo $PATH | grep ~/.local/bin`
3. If not in PATH, add to `~/.bashrc`: `export PATH="$HOME/.local/bin:$PATH"`
4. Reload shell: `source ~/.bashrc`

### Screenshot save fails

**Problem:** Error saving screenshot to default location.

**Solution:**
1. Create Pictures directory: `mkdir -p ~/Pictures/Screenshots`
2. Set permissions: `chmod 755 ~/Pictures/Screenshots`
3. Try again with custom output: `hyprshot -m region -o ~/test.png`

### Keybinding not working

**Problem:** Hyprland keybindings for screenshots don't work.

**Solutions:**
1. Verify Hyprshot is installed: `command -v hyprshot`
2. Restart Hyprland: Press `Super + Escape` to logout, then login again
3. Check keybindings in `config/hypr/hyprland.conf`
4. Try command directly: `hyprshot -m region`

### Requires Python/Dependencies

**Problem:** `hyprshot: command not found` or version mismatch.

**Solution:**
Hyprshot requires Python. Ensure it's installed:

```bash
python3 --version  # Should be Python 3.6+
```

If missing: `sudo apt install python3`

## Uninstalling Hyprshot

To remove Hyprshot:

1. **Via uninstall.sh** (Recommended):
   ```bash
   ./uninstall.sh
   ```
   When prompted: "Remove Hyprshot? (y/n)" → Select **y**

2. **Manual Removal**:
   ```bash
   # Remove symlink
   rm ~/.local/bin/hyprshot

   # Remove source (optional)
   rm -rf ~/Hyprshot
   ```

## Additional Resources

- **Hyprshot Repository:** https://github.com/Gustash/hyprshot
- **Hyprland Wiki - Bindings:** https://wiki.hyprland.org/Configuring/Binds/
- **Hyprland Wiki - Keybind Codes:** https://wiki.hyprland.org/Configuring/Binds/#key-names
