#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print error and exit
error_exit() {
    print_message "${RED}" "ERROR: $1"
    exit 1
}

# Check if script is run with root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error_exit "This script must be run as root or with sudo privileges."
    fi
}

# Detect OS and set package manager
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        
        case $OS in
            debian|ubuntu|mint|elementary|kali|zorin)
                PKG_MANAGER="apt-get"
                PKG_UPDATE="$PKG_MANAGER update"
                PKG_INSTALL="$PKG_MANAGER install -y"
                PACKAGES=(
                    "iproute2"
                    "wireless-tools"
                    "wpasupplicant"
                    "iw"
                    "net-tools"
                    "dnsutils"
                    "pciutils"
                    "network-manager"
                )
                print_message "${GREEN}" "Detected Debian-based system: $OS $VERSION"
                ;;
            rhel|fedora|centos|rocky|almalinux|ol)
                PKG_MANAGER="dnf"
                # Fall back to yum for older systems
                if ! command -v dnf &> /dev/null; then
                    PKG_MANAGER="yum"
                fi
                PKG_UPDATE="$PKG_MANAGER check-update || true"
                PKG_INSTALL="$PKG_MANAGER install -y"
                PACKAGES=(
                    "iproute"
                    "wireless-tools"
                    "wpa_supplicant"
                    "iw"
                    "net-tools"
                    "bind-utils"
                    "pciutils"
                    "NetworkManager"
                )
                print_message "${GREEN}" "Detected Red Hat-based system: $OS $VERSION"
                ;;
            arch|manjaro|endeavouros)
                PKG_MANAGER="pacman"
                PKG_UPDATE="$PKG_MANAGER -Sy"
                PKG_INSTALL="$PKG_MANAGER -S --noconfirm"
                PACKAGES=(
                    "iproute2"
                    "wireless-tools"
                    "wpa_supplicant"
                    "iw"
                    "net-tools"
                    "bind"
                    "pciutils"
                    "networkmanager"
                )
                print_message "${GREEN}" "Detected Arch-based system: $OS"
                ;;
            *)
                error_exit "Unsupported operating system: $OS"
                ;;
        esac
    else
        error_exit "Cannot detect operating system"
    fi
}

# Check if a command is available
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if a package is installed
check_package() {
    local package=$1
    local needed_command=$2
    
    print_message "${BLUE}" "Checking for $package..."
    
    if command_exists "$needed_command"; then
        print_message "${GREEN}" "✓ $package is already installed."
        return 0
    else
        print_message "${YELLOW}" "✗ $package needs to be installed."
        return 1
    fi
}

# Function to install packages
install_packages() {
    print_message "${CYAN}" "Updating package lists..."
    eval $PKG_UPDATE

    local installation_needed=false
    local packages_to_install=()
    
    # Define command to package mapping
    declare -A cmd_pkg_map
    cmd_pkg_map=( 
        ["ip"]="iproute2" 
        ["iwconfig"]="wireless-tools" 
        ["wpa_supplicant"]="wpasupplicant" 
        ["iw"]="iw" 
        ["ifconfig"]="net-tools" 
        ["dig"]="dnsutils" 
        ["lspci"]="pciutils" 
        ["nmcli"]="NetworkManager" 
    )
    
    # For RHEL/CentOS/Fedora systems, adjust package names
    if [[ "$OS" == "rhel" || "$OS" == "centos" || "$OS" == "fedora" || "$OS" == "rocky" || "$OS" == "almalinux" || "$OS" == "ol" ]]; then
        cmd_pkg_map["ip"]="iproute"
        cmd_pkg_map["dig"]="bind-utils"
        cmd_pkg_map["wpa_supplicant"]="wpa_supplicant"
    fi
    
    # For Arch-based systems, adjust package names
    if [[ "$OS" == "arch" || "$OS" == "manjaro" || "$OS" == "endeavouros" ]]; then
        cmd_pkg_map["dig"]="bind"
        cmd_pkg_map["nmcli"]="networkmanager"
    fi

    # Check if commands exist and add corresponding packages to install list if needed
    for cmd in "${!cmd_pkg_map[@]}"; do
        pkg="${cmd_pkg_map[$cmd]}"
        if ! command_exists "$cmd"; then
            print_message "${YELLOW}" "Command '$cmd' not found. Will install package '$pkg'."
            packages_to_install+=("$pkg")
            installation_needed=true
        else
            print_message "${GREEN}" "✓ Command '$cmd' is available."
        fi
    done
    
    # Install missing packages
    if [ "$installation_needed" = true ]; then
        print_message "${CYAN}" "Installing missing packages: ${packages_to_install[*]}"
        if $PKG_INSTALL "${packages_to_install[@]}"; then
            print_message "${GREEN}" "All required packages installed successfully!"
        else
            error_exit "Failed to install some packages. Please check the output for errors."
        fi
    else
        print_message "${GREEN}" "All required packages are already installed."
    fi
}

# Make wifi_troubleshooter.sh executable
make_executable() {
    if [ -f "wifi_troubleshooter.sh" ]; then
        print_message "${BLUE}" "Making wifi_troubleshooter.sh executable..."
        chmod +x wifi_troubleshooter.sh
        print_message "${GREEN}" "✓ wifi_troubleshooter.sh is now executable."
    else
        print_message "${YELLOW}" "Warning: wifi_troubleshooter.sh not found in current directory."
    fi
}

# Create symbolic link for wifi_troubleshooter.sh
create_symlink() {
    print_message "${BLUE}" "Setting up 'wifi-diagnostics' command..."
    
    # Get the absolute path of wifi_troubleshooter.sh
    SCRIPT_PATH="$(pwd)/wifi_troubleshooter.sh"
    if [ ! -f "$SCRIPT_PATH" ]; then
        print_message "${YELLOW}" "Warning: Could not find wifi_troubleshooter.sh in current directory."
        return 1
    fi
    
    # Check if the link already exists
    if [ -L "/usr/local/bin/wifi-diagnostics" ] || [ -f "/usr/local/bin/wifi-diagnostics" ]; then
        print_message "${YELLOW}" "A file or symbolic link already exists at /usr/local/bin/wifi-diagnostics."
        echo -n "Do you want to overwrite it? (y/n): "
        read -r overwrite
        if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
            print_message "${YELLOW}" "Skipping symbolic link creation."
            return 0
        fi
        print_message "${BLUE}" "Removing existing symbolic link..."
        rm -f "/usr/local/bin/wifi-diagnostics"
    fi
    
    # Create the symbolic link
    print_message "${BLUE}" "Creating symbolic link to $SCRIPT_PATH..."
    if ln -s "$SCRIPT_PATH" "/usr/local/bin/wifi-diagnostics"; then
        print_message "${GREEN}" "✓ Symbolic link created successfully."
        print_message "${GREEN}" "You can now run 'wifi-diagnostics' from anywhere."
    else
        print_message "${RED}" "✗ Failed to create symbolic link. You may need to run the script with sudo privileges."
    fi
}

# Main execution
main() {
    print_message "${PURPLE}" "===== WiFi Troubleshooter Installation Script ====="
    
    # Check for root/sudo privileges
    check_root
    
    # Detect OS and set package manager
    detect_os
    
    # Install required packages
    install_packages
    
    # Make wifi_troubleshooter.sh executable
    make_executable
    
    # Create symbolic link
    create_symlink
    
    print_message "${PURPLE}" "===== Installation Complete ====="
    print_message "${GREEN}" "You can now run ./wifi_troubleshooter.sh"
}

# Run the main function
main

