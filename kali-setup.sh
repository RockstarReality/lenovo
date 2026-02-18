#!/bin/bash

# ============================================================
# Kali Linux Post-Install Setup Script
# by RockstarReality
# ============================================================
# Installs:
#   - Flipper Zero (qFlipper AppImage)
#   - Netis WF2111 drivers (RTL8192CU)
#   - Alfa AWUS036ACH drivers (RTL8812AU)
#   - TP-Link TL-WN722N V2/V3 drivers (RTL8188EUS)
#
# Verified for Kali Linux kernel 6.x+
# ============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ============================================================
# HELPER FUNCTIONS
# ============================================================

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║          Kali Linux Post-Install Setup Script            ║"
    echo "║                   by RockstarReality                     ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✗ ERROR: $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info()    { echo -e "${BLUE}→ $1${NC}"; }

print_section() {
    echo ""
    echo -e "${WHITE}════════════════════════════════════════${NC}"
    echo -e "${WHITE}  $1${NC}"
    echo -e "${WHITE}════════════════════════════════════════${NC}"
    echo ""
}

press_enter() {
    echo ""
    read -p "Press Enter to continue..."
}

reboot_prompt() {
    echo ""
    print_warning "A reboot is REQUIRED to load the new drivers."
    print_warning "After rebooting, re-run this script to continue."
    read -p "Reboot now? (Y/n): " choice
    if [[ ! "$choice" =~ ^[Nn]$ ]]; then
        echo "Rebooting..."
        reboot
    else
        print_warning "Remember to reboot before using the new drivers!"
    fi
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root!"
        echo "Please run: sudo bash $0"
        exit 1
    fi
}

# ============================================================
# TMUX CHECK (runs at startup, before menu)
# ============================================================

check_tmux() {
    print_section "IMPORTANT: Tmux Recommendation"

    echo -e "${YELLOW}"
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │                                                     │"
    echo "  │   It is STRONGLY recommended to run this script     │"
    echo "  │   inside a TMUX session!                            │"
    echo "  │                                                     │"
    echo "  │   Why? Driver installations can take a long time.   │"
    echo "  │   If your terminal closes or SSH drops, tmux keeps  │"
    echo "  │   everything running safely in the background.      │"
    echo "  │                                                     │"
    echo "  │   How to use tmux:                                  │"
    echo "  │     tmux              <- Start new session          │"
    echo "  │     tmux attach       <- Re-attach if disconnected  │"
    echo "  │     Ctrl+B, D         <- Detach (keep running)      │"
    echo "  │                                                     │"
    echo "  └─────────────────────────────────────────────────────┘"
    echo -e "${NC}"

    # Already inside tmux?
    if [ -n "$TMUX" ]; then
        print_success "You are already inside a tmux session! Great job!"
        press_enter
        return
    fi

    # Tmux not installed?
    if ! command -v tmux &>/dev/null; then
        print_warning "Tmux is not installed!"
        read -p "Install tmux now? (Y/n): " choice
        if [[ ! "$choice" =~ ^[Nn]$ ]]; then
            apt install -y tmux
            print_success "Tmux installed!"
            echo ""
            echo -e "${YELLOW}Please restart this script inside tmux:${NC}"
            echo -e "  ${CYAN}tmux${NC}"
            echo -e "  ${CYAN}sudo bash $0${NC}"
            exit 0
        fi
    else
        print_success "Tmux is installed."
        echo ""
        read -p "Are you running this inside tmux? (y/N): " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            echo ""
            print_warning "Consider restarting inside tmux for safety:"
            echo -e "  ${CYAN}tmux${NC}"
            echo -e "  ${CYAN}sudo bash $0${NC}"
            echo ""
            read -p "Continue anyway without tmux? (y/N): " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo "Exiting. Please restart inside tmux!"
                exit 0
            fi
        fi
    fi
    press_enter
}

# ============================================================
# INSTALL FUNCTIONS
# ============================================================

install_flipper() {
    print_section "Installing Flipper Zero (qFlipper)"

    print_info "Using official qFlipper AppImage method"
    print_info "This is the recommended method for Kali Linux"
    echo ""

    # Dependencies
    print_info "Installing dependencies..."
    apt update
    apt install -y libfuse2 wget curl

    # Create install directory
    mkdir -p /opt/qflipper
    cd /opt/qflipper

    # Download latest qFlipper AppImage
    print_info "Downloading latest qFlipper AppImage from official source..."
    if wget -O qFlipper.AppImage \
        "https://update.flipperzero.one/builds/qFlipper/release/qFlipper-x86_64.AppImage"; then

        chmod +x qFlipper.AppImage

        # Install udev rules so Flipper is accessible without root
        print_info "Installing udev rules..."
        cat << 'EOF' | tee /etc/udev/rules.d/42-flipperzero.rules
# Flipper Zero - Serial interface
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", ATTRS{manufacturer}=="Flipper Devices Inc.", TAG+="uaccess", GROUP="plugdev", MODE="0664"
# Flipper Zero - DFU mode
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", ATTRS{manufacturer}=="STMicroelectronics", TAG+="uaccess", GROUP="plugdev", MODE="0664"
EOF

        udevadm control --reload-rules
        udevadm trigger

        # Add user to plugdev group
        REAL_USER=${SUDO_USER:-$USER}
        usermod -aG plugdev "$REAL_USER"
        print_success "Added $REAL_USER to plugdev group"

        # Desktop launcher
        cat << EOF > /usr/share/applications/qflipper.desktop
[Desktop Entry]
Type=Application
Name=qFlipper
Comment=Flipper Zero companion application
Icon=utilities-terminal
Exec=/opt/qflipper/qFlipper.AppImage
Terminal=false
Categories=Utility;
EOF

        # Terminal shortcut
        ln -sf /opt/qflipper/qFlipper.AppImage /usr/local/bin/qflipper

        echo ""
        print_success "qFlipper installed successfully!"
        print_info "Launch: qflipper (terminal) or search 'qFlipper' in app menu"
        print_warning "Log out and back in for group changes to take effect"

    else
        print_error "Download failed! Check your internet connection."
        print_info "Manual download: https://flipperzero.one/update"
    fi

    press_enter
}

install_netis_wf2111() {
    print_section "Installing Netis WF2111 Driver (RTL8192CU)"

    print_info "The Netis WF2111 uses the Realtek RTL8192CU chipset"
    echo ""

    # Dependencies
    print_info "Installing build dependencies..."
    apt update
    apt install -y build-essential dkms git linux-headers-$(uname -r) bc

    # Verify kernel headers installed
    if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
        print_error "Kernel headers missing! Please run:"
        print_info "sudo apt install linux-headers-$(uname -r)"
        print_info "Then run this script again."
        press_enter
        return
    fi

    # Use the correct RTL8192CU driver
    print_info "Cloning RTL8192CU driver..."
    cd /tmp
    rm -rf rtl8192cu

    if git clone https://github.com/pvaret/rtl8192cu-fixes.git rtl8192cu; then
        cd rtl8192cu

        print_info "Building driver (this may take a few minutes)..."
        if make; then
            make install

            # Blacklist the old default driver
            print_info "Blacklisting conflicting old drivers..."
            echo "blacklist rtl8192cu" | tee /etc/modprobe.d/rtl8192cu-fixes.conf
            echo "blacklist rtl8192c_common" >> /etc/modprobe.d/rtl8192cu-fixes.conf
            echo "blacklist rtlwifi" >> /etc/modprobe.d/rtl8192cu-fixes.conf

            print_success "Netis WF2111 driver installed!"
            print_info "Plug in your Netis WF2111 and check with: iwconfig"
            reboot_prompt
        else
            print_error "Build failed!"
            print_info "Check that kernel headers match your kernel: uname -r"
        fi
    else
        print_error "Failed to clone driver. Check your internet connection."
    fi

    press_enter
}

install_alfa_awus036ach() {
    print_section "Installing Alfa AWUS036ACH Driver (RTL8812AU)"

    print_info "The AWUS036ACH uses the Realtek RTL8812AU chipset"
    print_info "Using aircrack-ng fork - confirmed working on Kali kernel 6.x"
    echo ""

    # Dependencies
    print_info "Installing build dependencies..."
    apt update
    apt install -y build-essential dkms git linux-headers-$(uname -r) bc iw

    # Verify kernel headers
    if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
        print_error "Kernel headers missing! Please run:"
        print_info "sudo apt install linux-headers-$(uname -r)"
        print_info "Then run this script again."
        press_enter
        return
    fi

    # Remove any conflicting old drivers
    print_info "Removing conflicting old drivers if present..."
    dkms remove -m 8812au --all 2>/dev/null || true
    dkms remove -m 88XXau --all 2>/dev/null || true
    rmmod 88XXau 2>/dev/null || true
    rmmod 8812au 2>/dev/null || true

    # Clone specific working branch + commit
    print_info "Cloning RTL8812AU driver (v5.6.4.2 branch, commit 63cf0b4)..."
    print_info "This specific version is confirmed working on modern Kali kernels"
    cd /tmp
    rm -rf rtl8812au

    if git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git; then
        cd rtl8812au

        # Checkout confirmed working commit
        git checkout 63cf0b4

        # Install via DKMS - survives kernel updates!
        print_info "Installing via DKMS (survives kernel updates)..."
        if make dkms_install; then
            echo ""
            print_success "Alfa AWUS036ACH driver installed via DKMS!"
            print_success "Driver will survive kernel updates automatically"
            echo ""
            print_info "Plug in your AWUS036ACH and check with: iwconfig"
            print_info "Enable monitor mode:"
            print_info "  sudo airmon-ng check kill"
            print_info "  sudo airmon-ng start wlan0"
        else
            print_warning "DKMS install failed. Trying standard install..."
            if make && make install; then
                modprobe 88XXau 2>/dev/null || modprobe 8812au 2>/dev/null || true
                print_success "Driver installed (standard method)"
                print_warning "Note: May need reinstalling after kernel updates"
            else
                print_error "Installation failed. Please check error output above."
            fi
        fi
    else
        print_error "Failed to clone driver. Check your internet connection."
    fi

    press_enter
}

install_tplink_wn722n() {
    print_section "Installing TP-Link TL-WN722N V2/V3 Driver (RTL8188EUS)"

    print_info "TL-WN722N V2/V3 uses the Realtek RTL8188EUS chipset"
    print_info "This enables monitor mode and packet injection"
    echo ""
    print_warning "IMPORTANT NOTES:"
    print_warning "  - Blacklists BOTH r8188eu AND rtl8xxxu (required for kernel 6.x+)"
    print_warning "  - A REBOOT is required after installation"
    print_warning "  - Trying official Kali package first, then GitHub build as fallback"
    echo ""
    read -p "Continue? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Skipping TP-Link driver installation"
        press_enter
        return
    fi

    # Update first
    print_info "Updating package lists..."
    apt update

    # Method 1: Try Kali's official package first (cleanest method)
    print_info "Trying Kali's official package (realtek-rtl8188eus-dkms)..."
    if apt install -y realtek-rtl8188eus-dkms; then
        print_success "Official Kali package installed successfully!"

        # Still need to blacklist the old drivers on kernel 6.x
        print_info "Blacklisting old drivers (required for kernel 6.x+)..."
        echo 'blacklist r8188eu' | tee -a /etc/modprobe.d/realtek.conf
        echo 'blacklist rtl8xxxu' | tee -a /etc/modprobe.d/realtek.conf

    else
        # Method 2: Build from aircrack-ng GitHub
        print_warning "Official package not available. Building from GitHub..."

        # Install build dependencies
        print_info "Installing build dependencies..."
        apt install -y build-essential dkms git linux-headers-$(uname -r) bc libelf-dev

        # Verify kernel headers
        if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
            print_error "Kernel headers missing! Please run:"
            print_info "sudo apt install linux-headers-$(uname -r)"
            print_info "Then run this script again."
            press_enter
            return
        fi

        # Remove old driver module
        print_info "Removing old r8188eu module..."
        rmmod r8188eu 2>/dev/null || true

        # Blacklist old drivers BEFORE building (required for kernel 6.x+)
        print_info "Blacklisting old drivers (r8188eu and rtl8xxxu)..."
        echo 'blacklist r8188eu' | tee -a /etc/modprobe.d/realtek.conf
        echo 'blacklist rtl8xxxu' | tee -a /etc/modprobe.d/realtek.conf

        # Clone from aircrack-ng
        print_info "Cloning RTL8188EUS from aircrack-ng..."
        cd /tmp
        rm -rf rtl8188eus

        if git clone https://github.com/aircrack-ng/rtl8188eus.git; then
            cd rtl8188eus

            print_info "Building driver (this may take a few minutes)..."
            if make && make install; then
                print_success "RTL8188EUS driver built and installed!"
            else
                print_error "Build failed!"
                print_info "Try: sudo apt install linux-headers-$(uname -r)"
                print_info "Then run this installation again."
                press_enter
                return
            fi
        else
            print_error "Failed to clone driver. Check your internet connection."
            press_enter
            return
        fi
    fi

    # Post-install info
    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "After rebooting, enable monitor mode with:"
    print_info "  sudo airmon-ng check kill"
    print_info "  sudo ip link set wlan0 down"
    print_info "  sudo iw dev wlan0 set type monitor"
    print_info "  sudo ip link set wlan0 up"
    echo ""
    print_info "Or simply:"
    print_info "  sudo airmon-ng start wlan0"
    echo ""

    # Reboot required!
    reboot_prompt

    press_enter
}

install_all() {
    print_section "Installing Everything"
    print_warning "This will install ALL drivers and tools."
    print_warning "Total time: approximately 15-30 minutes."
    print_warning "Reboots may be required between installations."
    echo ""
    read -p "Are you sure? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        return
    fi

    install_flipper
    install_netis_wf2111
    install_alfa_awus036ach
    install_tplink_wn722n

    print_section "All Installations Complete!"
    print_success "Flipper Zero (qFlipper AppImage)"
    print_success "Netis WF2111 (RTL8192CU)"
    print_success "Alfa AWUS036ACH (RTL8812AU via DKMS)"
    print_success "TP-Link TL-WN722N V2/V3 (RTL8188EUS)"
    echo ""
    reboot_prompt
}

# ============================================================
# MAIN MENU
# ============================================================

show_menu() {
    print_banner

    echo -e "${WHITE}  What would you like to install?${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} Flipper Zero            (qFlipper AppImage - official)"
    echo -e "  ${CYAN}2)${NC} Netis WF2111             (RTL8192CU driver)"
    echo -e "  ${CYAN}3)${NC} Alfa AWUS036ACH           (RTL8812AU via DKMS)"
    echo -e "  ${CYAN}4)${NC} TP-Link TL-WN722N V2/V3   (RTL8188EUS - monitor mode)"
    echo -e "  ${CYAN}5)${NC} Install Everything"
    echo -e "  ${RED}0)${NC} Exit"
    echo ""
    echo -e "${WHITE}════════════════════════════════════════${NC}"
    read -p "  Enter your choice [0-5]: " choice

    case $choice in
        1) install_flipper ;;
        2) install_netis_wf2111 ;;
        3) install_alfa_awus036ach ;;
        4) install_tplink_wn722n ;;
        5) install_all ;;
        0)
            echo ""
            print_success "Exiting. Happy hacking!"
            echo ""
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 0-5."
            press_enter
            ;;
    esac
}

# ============================================================
# ENTRY POINT
# ============================================================

check_root
print_banner
check_tmux

while true; do
    show_menu
done
