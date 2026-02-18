#!/bin/bash
set -euo pipefail

LOGFILE="/var/log/kali-postinstall.log"
ERRORS=()
INSTALLED=()
SKIPPED=()

exec > >(tee -a "$LOGFILE") 2>&1

echo "================================================="
echo "Kali Linux Post-Install Script"
echo "Started: $(date)"
echo "Log file: $LOGFILE"
echo "================================================="

# ─────────────────────────────────────────────
# Root Check
# ─────────────────────────────────────────────
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root or with sudo"
   exit 1
fi

# ─────────────────────────────────────────────
# Helper Function
# ─────────────────────────────────────────────
install_if_missing() {
    if dpkg -s "$1" &>/dev/null; then
        echo "[SKIP] $1 already installed"
        SKIPPED+=("$1")
    else
        echo "[INSTALL] $1"
        if apt install -y "$1"; then
            INSTALLED+=("$1")
        else
            ERRORS+=("$1 failed to install")
        fi
    fi
}

# ─────────────────────────────────────────────
# System Update
# ─────────────────────────────────────────────
echo "[+] Updating system..."
apt update && apt upgrade -y && apt autoremove -y

# ─────────────────────────────────────────────
# APT Keyrings Setup
# ─────────────────────────────────────────────
echo "[+] Setting up APT keyrings..."
install -d -m 0755 /etc/apt/keyrings

# Sublime Text Repo
if [ ! -f /etc/apt/keyrings/sublimehq-pub.gpg ]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
        | gpg --dearmor -o /etc/apt/keyrings/sublimehq-pub.gpg
fi

echo "deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" \
    > /etc/apt/sources.list.d/sublime-text.list

# Brave Repo
if [ ! -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]; then
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
fi

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    > /etc/apt/sources.list.d/brave-browser-release.list

apt update

# ─────────────────────────────────────────────
# Additional Tools (Non-default Kali)
# ─────────────────────────────────────────────
echo "[+] Installing additional tools..."

PACKAGES=(
    sublime-text
    brave-browser
    clamav
    ufw
    maltego
    redshift
    openvpn
    network-manager-openvpn
    vlc
)

for pkg in "${PACKAGES[@]}"; do
    install_if_missing "$pkg"
done

# ─────────────────────────────────────────────
# Kali Wallpapers (Auto-detect)
# ─────────────────────────────────────────────
echo "[+] Installing Kali wallpapers..."

WALLPAPER_PACKAGES=$(apt-cache search "^kali-wallpapers" | awk '{print $1}')

if [ -z "$WALLPAPER_PACKAGES" ]; then
    echo "[WARN] No kali-wallpapers packages found"
    ERRORS+=("No kali-wallpapers packages available")
else
    for wp in $WALLPAPER_PACKAGES; do
        install_if_missing "$wp"
    done
fi

# ─────────────────────────────────────────────
# UFW Configuration (Safe Defaults)
# ─────────────────────────────────────────────
echo "[+] Configuring UFW firewall..."

install_if_missing ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 9050/tcp   # Tor
ufw allow 53         # DNS
ufw logging on

echo "y" | ufw enable

# ─────────────────────────────────────────────
# ClamAV Update
# ─────────────────────────────────────────────
if command -v freshclam &>/dev/null; then
    echo "[+] Updating ClamAV signatures..."
    freshclam || ERRORS+=("ClamAV signature update failed")
fi

# ─────────────────────────────────────────────
# Final Summary
# ─────────────────────────────────────────────
echo ""
echo "================================================="
echo "POST-INSTALL SUMMARY"
echo "================================================="

echo ""
echo "Installed Packages:"
if [ ${#INSTALLED[@]} -eq 0 ]; then
    echo "  None"
else
    for item in "${INSTALLED[@]}"; do
        echo "  ✔ $item"
    done
fi

echo ""
echo "Already Installed (Skipped):"
if [ ${#SKIPPED[@]} -eq 0 ]; then
    echo "  None"
else
    for item in "${SKIPPED[@]}"; do
        echo "  ➜ $item"
    done
fi

echo ""
echo "Errors:"
if [ ${#ERRORS[@]} -eq 0 ]; then
    echo "  None 🎉"
else
    for item in "${ERRORS[@]}"; do
        echo "  ✖ $item"
    done
fi

echo ""
echo "Firewall Status:"
ufw status verbose

echo ""
echo "Log saved to: $LOGFILE"
echo "Completed: $(date)"
echo "================================================="
