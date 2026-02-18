# THIS README IS MAINLY FOR THE LENOVO BRIGHTNESS FIX FOR LENOVO LAPTOPS:

# Other files included in this repository:
"kali_personalized.sh" is an installer script that installs some wallpapers and apps for my personal preference.
"kali-setup.sh" helps out to install drivers for some adapters that I like to be able to access from my github if needed.
"monitor-mode-cheatsheet.html" is a small cheat sheet for use after "kali-setup.sh" if I ever hit my head too hard.




# 🌞 Brightness Control Fix for Lenovo Laptops with NVIDIA + Nouveau


curl -fsSL https://raw.githubusercontent.com/RockstarReality/lenovo/refs/heads/main/brightness-fix-installer.sh | bash
wget -qO- https://raw.githubusercontent.com/RockstarReality/lenovo/refs/heads/main/brightness-fix-installer.sh | bash


🚨 The Problem
If you have a Lenovo laptop with an NVIDIA GPU running in discrete graphics mode with the Nouveau driver, your brightness controls don't work. The slider moves, but the screen brightness stays the same.
Affected Systems:

Lenovo Legion series (5, 7, Pro, Slim)
Lenovo LOQ series
Other Lenovo laptops with NVIDIA GPUs in discrete-only mode
Running Nouveau driver (not proprietary NVIDIA drivers)
Kali Linux, Ubuntu, Debian, Arch, and other Linux distributions


✨ The Solution
This tool provides software-based brightness control using xrandr plus color temperature adjustment using redshift, all wrapped in a beautiful GUI menu.
Features:

🎚️ 5 brightness presets (10%, 30%, 50%, 70%, 100%)
🌡️ 6 color temperature presets (2500K-6500K)
🖱️ One-click access from system panel
⌨️ Keyboard shortcut support
🔄 Quick reset to default settings
💾 Zero configuration - auto-detects your display
🛡️ 100% safe - no driver modifications


🚀 Quick Install
One-Line Install (Recommended)
bash curl -fsSL https://raw.githubusercontent.com/RockstarReality/lenovo/refs/heads/main/brightness-fix-installer.sh| bash
Or with wget:
bash wget -qO- https://raw.githubusercontent.com/RockstarReality/lenovo/refs/heads/main/brightness-fix-installer.sh | bash
Manual Install

Download the installer:

bash wget https://raw.githubusercontent.com/RockstarReality/lenovo/refs/heads/main/brightness-fix-installer.sh

Make it executable:

bash chmod +x brightness-fix-installer.sh

Run it:

bash ./brightness-fix-installer.sh

Follow the on-screen instructions!


📋 Requirements

OS: Linux (Debian-based preferred: Kali, Ubuntu, Debian, etc.)
Desktop Environment: XFCE (works on others too with minor tweaks)
Display Server: X11 (not Wayland)
Packages: xrandr, zenity, redshift (auto-installed by script)


🎯 Usage
From Application Menu

Open your application menu
Search for "Brightness Control"
Click to open the control panel
Select your desired brightness or color temperature

From Command Line
bash~/.local/bin/brightness-menu-zenity.sh
Add to XFCE Panel

Right-click on XFCE panel → Panel → Panel Preferences
Click Items tab → + button
Add Launcher
Right-click the new launcher → Properties
Click + → Search for "Brightness Control" → Add

Keyboard Shortcuts (Optional)
Add these in Settings → Keyboard → Application Shortcuts:
CommandSuggested Shortcutxrandr --output eDP-1 --brightness 0.3Ctrl+Alt+1 (30%)xrandr --output eDP-1 --brightness 0.5Ctrl+Alt+2 (50%)xrandr --output eDP-1 --brightness 0.7Ctrl+Alt+3 (70%)xrandr --output eDP-1 --brightness 1.0Ctrl+Alt+4 (100%)~/.local/bin/brightness-menu-zenity.shCtrl+Alt+B (Menu)
Note: Replace eDP-1 with your actual display name

🎨 Available Settings
Brightness Levels

10% - Very Dim (late night reading)
30% - Dim (evening use)
50% - Medium (general use)
70% - Bright (daytime)
100% - Full Brightness (outdoor/bright rooms)

Color Temperature (Redshift)

2500K - Ultra Warm (deep orange, perfect for sleep prep)
3000K - Very Warm (orange-ish, late evening)
3500K - Warm (comfortable evening setting)
4500K - Evening (slight warmth)
5500K - Daylight (neutral-cool)
6500K - Neutral/Off (default, no filter)

Reset Option

Reset Everything - Returns brightness to 100% and color to neutral


🔧 Manual Commands
If you prefer command-line control:
bash# Adjust brightness
xrandr --output eDP-1 --brightness 0.5   # 50%
xrandr --output eDP-1 --brightness 1.0   # 100%

# Adjust color temperature
redshift -O 3500   # Set to 3500K
redshift -x        # Reset to neutral

# Reset everything
xrandr --output eDP-1 --brightness 1.0 && redshift -x

🐛 Troubleshooting
"zenity: command not found"
bashsudo apt install zenity
"redshift: command not found"
bashsudo apt install redshift
"No protocol specified" or display errors
Make sure you're running from within an X11 session, not from SSH or TTY.
Wrong display name
Find your display name:
bashxrandr | grep " connected"
Then edit the script and replace eDP-1 with your display name:
bashnano ~/.local/bin/brightness-menu-zenity.sh
Reset to defaults
bashxrandr --output eDP-1 --brightness 1.0
redshift -x
```

---

## ❓ FAQ

### Why not use hardware brightness control?

Hardware brightness control requires either:
- **Hybrid graphics mode** with integrated GPU enabled (often not available in BIOS)
- **NVIDIA proprietary drivers** (frequently break on kernel updates and can cause system instability)

This software solution is **stable, safe, and works on every kernel version**.

### Does this actually change the backlight?

No, this uses **software dimming** (reduces pixel output) rather than hardware backlight control. The effect is nearly identical for most users, and it has the benefit of never breaking.

### Will this work on non-Lenovo laptops?

Yes! This works on **any laptop** where hardware brightness control is broken or unavailable. Just run the installer and it will auto-detect your display.

### Does this work on Wayland?

No, this requires X11. Wayland uses different display protocols and would need a different solution.

### Can I add more presets?

Yes! Edit `~/.local/bin/brightness-menu-zenity.sh` and add more options to the zenity list and case statements.

---

## 🧪 Tested On

| System | Status |
|--------|--------|
| Lenovo LOQ + RTX 4050 + Nouveau | ✅ Working |
| Lenovo Legion 5 + RTX 3060 + Nouveau | ✅ Working |
| Kali Linux (Debian) | ✅ Working |
| Ubuntu 22.04/24.04 | ✅ Working |
| Arch Linux | ✅ Working |
| Fedora | ⚠️ Untested (should work) |

---

## 📁 File Structure
```
~/.local/bin/brightness-menu-zenity.sh          # Main control script
~/.local/share/applications/brightness-control.desktop   # Desktop launcher

🔄 Uninstall
To remove the brightness control:
bashrm ~/.local/bin/brightness-menu-zenity.sh
rm ~/.local/share/applications/brightness-control.desktop
To also remove the packages:
bashsudo apt remove zenity redshift

🤝 Contributing
Contributions are welcome! Feel free to:

🐛 Report bugs
💡 Suggest features
🔧 Submit pull requests
📖 Improve documentation
🎨 Add screenshots


📜 License
Public Domain - This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

🙏 Acknowledgments

Developed through diagnostic troubleshooting of Lenovo laptop brightness issues
Thanks to the Linux community for xrandr and redshift tools
Special thanks to everyone who deals with NVIDIA + Linux on a daily basis 😅


📞 Support

Issues: GitHub Issues
Discussions: GitHub Discussions


⭐ Star This Repo!
If this fixed your brightness problem, please give it a star! It helps others find the solution.

Made with ❤️ and frustration by someone who's been there
"Because life's too short to debug NVIDIA drivers"
