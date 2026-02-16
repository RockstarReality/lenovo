#!/bin/bash
#nano ~/brightness-fix-installer.sh

# Brightness Control Auto-Installer for Lenovo Laptops with NVIDIA + Nouveau
# Works on Kali Linux and other Debian-based systems

echo "================================================"
echo "Brightness Control Fix - Auto Installer"
echo "================================================"
echo ""
echo "This will install a brightness control menu for"
echo "Lenovo laptops with NVIDIA GPUs using Nouveau driver"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Detect display name
echo ""
echo "Detecting your display..."
DISPLAY_NAME=$(xrandr | grep " connected" | awk '{print $1}' | head -1)

if [ -z "$DISPLAY_NAME" ]; then
    echo "ERROR: Could not detect display name!"
    echo "Please run 'xrandr | grep connected' manually and note your display name"
    exit 1
fi

echo "✓ Display detected: $DISPLAY_NAME"

# Install required packages
echo ""
echo "Installing required packages (zenity, redshift)..."
sudo apt update
sudo apt install -y zenity redshift

if [ $? -ne 0 ]; then
    echo "ERROR: Package installation failed!"
    exit 1
fi

echo "✓ Packages installed"

# Create directories
echo ""
echo "Creating directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications

echo "✓ Directories created"

# Create the brightness control script
echo ""
echo "Creating brightness control script..."

cat > ~/.local/bin/brightness-menu-zenity.sh << 'EOFSCRIPT'
#!/bin/bash

# Ultimate Display Control - Brightness + Redshift
CHOICE=$(zenity --list \
    --title="Display Control" \
    --text="Select brightness or color temperature:" \
    --column="Setting" \
    --height=500 \
    --width=350 \
    "Brightness: 10% (Very Dim)" \
    "Brightness: 30% (Dim)" \
    "Brightness: 50% (Medium)" \
    "Brightness: 70% (Bright)" \
    "Brightness: 100% (Full)" \
    "Redshift: 2500K (Ultra Warm/Night)" \
    "Redshift: 3000K (Very Warm/Late Night)" \
    "Redshift: 3500K (Warm)" \
    "Redshift: 4500K (Evening)" \
    "Redshift: 5500K (Daylight)" \
    "Redshift: 6500K (Neutral/Off)" \
    "Reset Everything (100% + Neutral)")

case "$CHOICE" in
    "Brightness: 10% (Very Dim)")
        xrandr --output DISPLAY_NAME_PLACEHOLDER --brightness 0.1
        zenity --info --text="Brightness set to 10%" --timeout=1 --width=200
        ;;
    "Brightness: 30% (Dim)")
        xrandr --output DISPLAY_NAME_PLACEHOLDER --brightness 0.3
        zenity --info --text="Brightness set to 30%" --timeout=1 --width=200
        ;;
    "Brightness: 50% (Medium)")
        xrandr --output DISPLAY_NAME_PLACEHOLDER --brightness 0.5
        zenity --info --text="Brightness set to 50%" --timeout=1 --width=200
        ;;
    "Brightness: 70% (Bright)")
        xrandr --output DISPLAY_NAME_PLACEHOLDER --brightness 0.7
        zenity --info --text="Brightness set to 70%" --timeout=1 --width=200
        ;;
    "Brightness: 100% (Full)")
        xrandr --output DISPLAY_NAME_PLACEHOLDER --brightness 1.0
        zenity --info --text="Brightness set to 100%" --timeout=1 --width=200
        ;;
    "Redshift: 2500K (Ultra Warm/Night)")
        redshift -O 2500
        zenity --info --text="Color Temp set to 2500K (Ultra Warm)" --timeout=1 --width=250
        ;;
    "Redshift: 3000K (Very Warm/Late Night)")
        redshift -O 3000
        zenity --info --text="Color Temp set to 3000K (Very Warm)" --timeout=1 --width=250
        ;;
    "Redshift: 3500K (Warm)")
        redshift -O 3500
        zenity --info --text="Color Temp set to 3500K (Warm)" --timeout=1 --width=250
        ;;
    "Redshift: 4500K (Evening)")
        redshift -O 4500
        zenity --info --text="Color Temp set to 4500K (Evening)" --timeout=1 --width=250
        ;;
    "Redshift: 5500K (Daylight)")
        redshift -O 5500
        zenity --info --text="Color Temp set to 5500K (Daylight)" --timeout=1 --width=250
        ;;
    "Redshift: 6500K (Neutral/Off)")
        redshift -x
        zenity --info --text="Color Temp set to 6500K (Neutral)" --timeout=1 --width=250
        ;;
    "Reset Everything (100% + Neutral)")
        xrandr --output DISPLAY_NAME_PLACEHOLDER --brightness 1.0
        redshift -x
        zenity --info --text="Everything Reset!\nBrightness: 100%\nColor: Neutral" --timeout=2 --width=250
        ;;
esac
EOFSCRIPT

# Replace placeholder with actual display name
sed -i "s/DISPLAY_NAME_PLACEHOLDER/$DISPLAY_NAME/g" ~/.local/bin/brightness-menu-zenity.sh

# Make script executable
chmod +x ~/.local/bin/brightness-menu-zenity.sh

echo "✓ Brightness control script created"

# Create desktop launcher
echo ""
echo "Creating desktop launcher..."

cat > ~/.local/share/applications/brightness-control.desktop << EOF
[Desktop Entry]
Type=Application
Name=Brightness Control
Comment=Quick brightness and color temperature control
Icon=preferences-desktop-display
Exec=$HOME/.local/bin/brightness-menu-zenity.sh
Terminal=false
Categories=Utility;Settings;
EOF

chmod +x ~/.local/share/applications/brightness-control.desktop

echo "✓ Desktop launcher created"

# Test the script
echo ""
echo "Testing brightness control..."
if ~/.local/bin/brightness-menu-zenity.sh &>/dev/null; then
    echo "✓ Script test successful"
else
    echo "! Script executed (close the dialog to continue)"
fi

# Final instructions
echo ""
echo "================================================"
echo "✓ Installation Complete!"
echo "================================================"
echo ""
echo "Your display: $DISPLAY_NAME"
echo ""
echo "How to use:"
echo "1. Search for 'Brightness Control' in your application menu"
echo "2. Or run: ~/.local/bin/brightness-menu-zenity.sh"
echo ""
echo "To add to XFCE panel:"
echo "1. Right-click panel → Panel → Panel Preferences"
echo "2. Items tab → + button → Add 'Launcher'"
echo "3. Right-click new launcher → Properties → +"
echo "4. Search 'Brightness Control' → Add"
echo ""
echo "Quick test commands:"
echo "  xrandr --output $DISPLAY_NAME --brightness 0.5"
echo "  xrandr --output $DISPLAY_NAME --brightness 1.0"
echo ""
echo "To reset everything:"
echo "  xrandr --output $DISPLAY_NAME --brightness 1.0"
echo "  redshift -x"
echo ""
echo "Enjoy your working brightness control! 🎉"
echo "================================================"
