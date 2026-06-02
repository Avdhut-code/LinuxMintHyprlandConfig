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
> - **Original Repository:** [JaKooLit/Ubuntu-Hyprland](https://github.com)

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

# Theme installation steps

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

# Structure of .dotfile

my dotfile repo is simple setup at a single place the parent cloned repo folder from where the whole setup is connected , after cloning and running `install.sh` the whole folder gets copied to `~/.local/share/dotFileRepo` from where all the simlinks ar created to appropriate `User` specific locations such as - location - location - location

    # file structure preview
    .
    ├── .bashrc
    ├── bin
    │   ├── brightnessCheck.sh
    │   ├── codecho.sh
    │   ├── custom-launch-btop.sh
    │   ├── custom-open-link.sh
    │   ├── gnome-terExit.sh
    │   ├── startup.sh
    │   └── wofiDrawer.sh
    ├── config
    │   ├── hypr
    │   │   ├── hypridle.conf
    │   │   ├── hyprland.conf
    │   │   ├── hyprlock.conf
    │   │   ├── webappsbinds.conf
    │   │   └── workspace.conf
    │   └── wofi
    │       ├── config
    │       ├── SearchBarStyle.css
    │       └── style.css
    ├── folderStructure.txt
    ├── icon
    │   ├── brightnessDecrease.png
    │   ├── brightnessIncrease.png
    │   ├── brightnessReset.png
    │   ├── chatgpt.png
    │   ├── claude.png
    │   ├── github-light.png
    │   ├── google-calendar.png
    │   ├── google-gemini.png
    │   ├── google-notebooklm.png
    │   ├── google-tasks.png
    │   ├── perplexity.png
    │   ├── playerctl-play-pause.png
    │   ├── whatsapp.png
    │   └── youtube.png
    ├── install.sh
    ├── PreviewImage2.png
    ├── PreviewImage3.png
    ├── PreviewImage.png
    ├── README.md
    ├── tools.conf
    └── wallpaper
        ├── wall1.png
        ├── wall2.png
        ├── wall3.png
        ├── wall4.png
        └── wall5.png

    10 directories, 41 files

---

# Installation

1 june
