<p align="center">
  <img src="https://img.shields.io/badge/script-Bash-blue?logo=gnu-bash" alt="Bash">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome">
</p>

<p align="center">
  <img src="https://github.com/DouglasFreshHabian/MorseBash/blob/main/Graphics/Tux-Spy-Telegraph.png?raw=true" alt="My Image" width="400">
</p>

<h1 align="center">
🔊 MorseBash.sh
	</h1>

[MorseBash.sh](https://github.com/DouglasFreshHabian/MorseBash/blob/main/morseBash.sh) is a fun and colorful Bash script that converts text into Morse code with both **audio playback** and **live visual output**. It plays dots and dashes using `aplay`, displays real-time `.` and `-` characters, and includes a randomly colored ASCII art banner for style.

---

## ✨ Features

- 🔈 **Audio output**: Plays `dot.wav` and `dash.wav` using `aplay`
- 👀 **Visual output**: Prints `.` and `-` characters for each Morse symbol
- 🌈 **ASCII banner**: Styled with a randomly selected color on each run
- 🔤 Supports lowercase a–z, numbers 0–9, and some punctuation
- 📦 Minimal dependencies (just `aplay`)

---

## 🚀 Usage

```bash
./morse.sh your message here
```
> If no arguments are given, a sample message is played to demonstrate usage.
---

## 🎵 Requirements

* aplay (usually provided by the alsa-utils package on Debian-based systems)

* dot.wav and dash.wav in the same directory as the script

To install aplay:
```bash
sudo apt install alsa-utils
```

## 📂 Example
Play hello world
```bash
$ ./morse.sh hello world
```
Output:
```bash
.... . .-.. .-.. ---   .-- --- .-. .-.. -..
```
(Plus audible Morse code tones.)

## 💬 [License](https://github.com/DouglasFreshHabian/MorseBash/blob/main/LICENSE)

MIT License. Feel free to use, modify, and share.

## 〰️ May the Morse be with you!
[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&color=FFF7FE&width=435&lines=..-.+.-.+.+...+....+++;+..-.+---+.-.+.+-.+...+..+-.-.+...)](https://git.io/typing-svg)



<!-- echo dfresh9tutanota1com|tr 91 @.  -->
