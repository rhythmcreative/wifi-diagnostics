#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Array to track failed packages
declare -a failed_packages=()

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}Installing WiFi Diagnostics Tool...${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Detect package manager
if command_exists pacman; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="pacman -S --noconfirm --needed"
    UPDATE_CMD="pacman -Sy"
    # Define mappings for Arch Linux packages
    declare -A ARCH_PKG_MAP=(
        ["python3"]="python"
        ["python-pip"]="python-pip"
        ["iproute2"]="iproute2"
        ["wireless-tools"]="wireless_tools"
        ["net-tools"]="net-tools"
        ["iw"]="iw"
        ["NetworkManager"]="networkmanager"
        ["wpa_supplicant"]="wpa_supplicant"
        ["dhcpcd"]="dhcpcd"
        ["dhclient"]="dhclient"
        ["pciutils"]="pciutils"
        ["rfkill"]="util-linux"
        ["lshw"]="lshw"
        ["speedtest-cli"]="speedtest-cli"
        ["nmap"]="nmap"
        ["tcpdump"]="tcpdump"
        ["netcat-openbsd"]="openbsd-netcat"
        ["bind-utils"]="bind-tools"
        ["dnsutils"]="bind-tools"
        ["iptables"]="iptables"
        ["curl"]="curl"
        ["wget"]="wget"
        ["bc"]="bc"
    )
elif command_exists apt-get; then
    PKG_MANAGER="apt"
    INSTALL_CMD="apt-get install -y"
    UPDATE_CMD="apt-get update"
    # Package name mappings for Debian/Ubuntu
    PKG_MAP=(
        "bind-utils:dnsutils"
        "netcat-openbsd:netcat-openbsd"
    )
elif command_exists dnf; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="dnf install -y"
    UPDATE_CMD="dnf check-update"
    # Package name mappings for Fedora
    PKG_MAP=(
        "dnsutils:bind-utils"
        "netcat-openbsd:netcat"
    )
elif command_exists yum; then
    PKG_MANAGER="yum"
    INSTALL_CMD="yum install -y"
    UPDATE_CMD="yum check-update"
    # Package name mappings for CentOS/RHEL
    PKG_MAP=(
        "dnsutils:bind-utils"
        "netcat-openbsd:nmap-ncat"
        "dhclient:dhcp-client"
    )
else
    echo -e "${RED}No supported package manager found. Please install dependencies manually.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected package manager: $PKG_MANAGER${NC}"

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
eval "$UPDATE_CMD"

echo -e "${BLUE}Installing dependencies...${NC}"

# Process each package from requirements.txt
while read package; do
    # Skip empty lines and comments
    if [[ -z "$package" || "$package" =~ ^[[:space:]]*$ || "$package" =~ ^# ]]; then
        continue
    fi
    
    # Trim whitespace
    package=$(echo "$package" | xargs)
    
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        # For Arch Linux, handle package mapping
        if [[ -n "${ARCH_PKG_MAP[$package]}" ]]; then
            mapped_package="${ARCH_PKG_MAP[$package]}"
            echo -e "${BLUE}Installing: $package (mapped to ${mapped_package})${NC}"
        else
            mapped_package="$package"
            echo -e "${YELLOW}No mapping found for $package, using original name${NC}"
        fi
        
        # Check if package is already installed
        if pacman -Qi "$mapped_package" &>/dev/null; then
            echo -e "${GREEN}Package $mapped_package is already installed${NC}"
        else
            echo -e "${BLUE}Installing package: $mapped_package${NC}"
            if eval "$INSTALL_CMD $mapped_package"; then
                echo -e "${GREEN}Successfully installed $mapped_package${NC}"
            else
                echo -e "${RED}Failed to install $mapped_package${NC}"
                failed_packages+=("$package -> $mapped_package")
            fi
        fi
    else
        # For other package managers
        mapped_package="$package"
        # Apply package mapping if available
        for mapping in "${PKG_MAP[@]}"; do
            original=$(echo "$mapping" | cut -d: -f1)
            mapped=$(echo "$mapping" | cut -d: -f2)
            if [[ "$package" == "$original" ]]; then
                mapped_package="$mapped"
                echo -e "${BLUE}Mapping package: $package -> $mapped_package${NC}"
                break
            fi
        done
        
        echo -e "${BLUE}Installing package: $mapped_package${NC}"
        if eval "$INSTALL_CMD $mapped_package"; then
            echo -e "${GREEN}Successfully installed $mapped_package${NC}"
        else
            echo -e "${RED}Failed to install $mapped_package${NC}"
            failed_packages+=("$package -> $mapped_package")
        fi
    fi
done < requirements.txt

# Make script executable
echo -e "${BLUE}Setting up executable...${NC}"
chmod +x wifi_troubleshooter.sh

# Create symbolic link
ln -sf "$(pwd)/wifi_troubleshooter.sh" /usr/local/bin/wifi-diagnostics

# Report any failed packages
if [ ${#failed_packages[@]} -ne 0 ]; then
    echo -e "${YELLOW}The following packages failed to install:${NC}"
    printf '%s\n' "${failed_packages[@]}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can now run the tool by typing: ${BLUE}wifi-diagnostics${NC}"

#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Array to track failed packages
declare -a failed_packages=()

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}Installing WiFi Diagnostics Tool...${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Detect package manager
if command_exists pacman; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="pacman -S --noconfirm --needed"
    UPDATE_CMD="pacman -Sy"
elif command_exists apt-get; then
    PKG_MANAGER="apt"
    INSTALL_CMD="apt-get install -y"
    UPDATE_CMD="apt-get update"
elif command_exists dnf; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="dnf install -y"
    UPDATE_CMD="dnf check-update"
elif command_exists yum; then
    PKG_MANAGER="yum"
    INSTALL_CMD="yum install -y"
    UPDATE_CMD="yum check-update"
else
    echo -e "${RED}No supported package manager found. Please install dependencies manually.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected package manager: $PKG_MANAGER${NC}"

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
eval "$UPDATE_CMD"

# Define package mappings for different distributions
if [[ "$PKG_MANAGER" == "pacman" ]]; then
    # Define mappings for Arch Linux packages
    declare -A ARCH_PKG_MAP=(
        ["python3"]="python"
        ["python-pip"]="python-pip"
        ["iproute2"]="iproute2"
        ["wireless-tools"]="wireless_tools"
        ["net-tools"]="net-tools"
        ["iw"]="iw"
        ["NetworkManager"]="networkmanager"
        ["wpa_supplicant"]="wpa_supplicant"
        ["dhcpcd"]="dhcpcd"
        ["dhclient"]="dhclient"
        ["pciutils"]="pciutils"
        ["rfkill"]="util-linux"
        ["lshw"]="lshw"
        ["speedtest-cli"]="speedtest-cli"
        ["nmap"]="nmap"
        ["tcpdump"]="tcpdump"
        ["netcat-openbsd"]="openbsd-netcat"
        ["bind-utils"]="bind-tools"
        ["dnsutils"]="bind-tools"
        ["iptables"]="iptables"
        ["curl"]="curl"
        ["wget"]="wget"
        ["bc"]="bc"
    )
elif [[ "$PKG_MANAGER" == "apt" ]]; then
    PKG_MAP=(
        "bind-utils:dnsutils"
        "netcat-openbsd:netcat-openbsd"
    )
elif [[ "$PKG_MANAGER" == "dnf" ]]; then
    PKG_MAP=(
        "dnsutils:bind-utils"
        "netcat-openbsd:netcat"
    )
elif [[ "$PKG_MANAGER" == "yum" ]]; then
    PKG_MAP=(
        "dnsutils:bind-utils"
        "netcat-openbsd:nmap-ncat"
        "dhclient:dhcp-client"
    )
fi

echo -e "${BLUE}Installing dependencies...${NC}"

# Process each package from requirements.txt
while read package; do
    # Skip empty lines and comments
    if [[ -z "$package" || "$package" =~ ^[[:space:]]*$ || "$package" =~ ^# ]]; then
        continue
    fi
    
    # Trim whitespace
    package=$(echo "$package" | xargs)
    
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        # For Arch Linux, handle package mapping
        if [[ -n "${ARCH_PKG_MAP[$package]}" ]]; then
            mapped_package="${ARCH_PKG_MAP[$package]}"
            echo -e "${BLUE}Installing: $package (mapped to ${mapped_package})${NC}"
        else
            mapped_package="$package"
            echo -e "${YELLOW}No mapping found for $package, using original name${NC}"
        fi
        
        # Check if package is already installed
        if pacman -Qi "$mapped_package" &>/dev/null; then
            echo -e "${GREEN}Package $mapped_package is already installed${NC}"
        else
            echo -e "${BLUE}Installing package: $mapped_package${NC}"
            if eval "$INSTALL_CMD $mapped_package"; then
                echo -e "${GREEN}Successfully installed $mapped_package${NC}"
            else
                echo -e "${RED}Failed to install $mapped_package${NC}"
                failed_packages+=("$package -> $mapped_package")
            fi
        fi
    else
        # For other package managers
        mapped_package="$package"
        # Apply package mapping if available
        for mapping in "${PKG_MAP[@]}"; do
            original=$(echo "$mapping" | cut -d: -f1)
            mapped=$(echo "$mapping" | cut -d: -f2)
            if [[ "$package" == "$original" ]]; then
                mapped_package="$mapped"
                echo -e "${BLUE}Mapping package: $package -> $mapped_package${NC}"
                break
            fi
        done
        
        echo -e "${BLUE}Installing package: $mapped_package${NC}"
        if eval "$INSTALL_CMD $mapped_package"; then
            echo -e "${GREEN}Successfully installed $mapped_package${NC}"
        else
            echo -e "${RED}Failed to install $mapped_package${NC}"
            failed_packages+=("$package -> $mapped_package")
        fi
    fi
done < requirements.txt

# Make script executable
echo -e "${BLUE}Setting up executable...${NC}"
chmod +x wifi_troubleshooter.sh

# Create symbolic link
ln -sf "$(pwd)/wifi_troubleshooter.sh" /usr/local/bin/wifi-diagnostics

# Report any failed packages
if [ ${#failed_packages[@]} -ne 0 ]; then
    echo -e "${YELLOW}The following packages failed to install:${NC}"
    printf '%s\n' "${failed_packages[@]}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can now run the tool by typing: ${BLUE}wifi-diagnostics${NC}"

#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Array to track failed packages
declare -a failed_packages=()

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}Installing WiFi Diagnostics Tool...${NC}"

# Detect package manager
if command_exists pacman; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="pacman -S --noconfirm --needed"
    UPDATE_CMD="pacman -Sy"
elif command_exists apt-get; then
    PKG_MANAGER="apt"
    INSTALL_CMD="apt-get install -y"
    UPDATE_CMD="apt-get update"
elif command_exists dnf; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="dnf install -y"
    UPDATE_CMD="dnf check-update"
elif command_exists yum; then
    PKG_MANAGER="yum"
    INSTALL_CMD="yum install -y"
    UPDATE_CMD="yum check-update"
else
    echo -e "${RED}No supported package manager found. Please install dependencies manually.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected package manager: $PKG_MANAGER${NC}"

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
eval "$UPDATE_CMD"

# Define package mappings for different distributions
if [[ "$PKG_MANAGER" == "pacman" ]]; then
    # Define mappings for Arch Linux packages
    declare -A ARCH_PKG_MAP=(
        ["python3"]="python"
        ["python-pip"]="python-pip"
        ["iproute2"]="iproute2"
        ["wireless-tools"]="wireless_tools"
        ["net-tools"]="net-tools"
        ["iw"]="iw"
        ["NetworkManager"]="networkmanager"
        ["wpa_supplicant"]="wpa_supplicant"
        ["dhcpcd"]="dhcpcd"
        ["dhclient"]="dhclient"
        ["pciutils"]="pciutils"
        ["rfkill"]="util-linux"
        ["lshw"]="lshw"
        ["speedtest-cli"]="speedtest-cli"
        ["nmap"]="nmap"
        ["tcpdump"]="tcpdump"
        ["netcat-openbsd"]="openbsd-netcat"
        ["bind-utils"]="bind-tools"
        ["dnsutils"]="bind-tools"
        ["iptables"]="iptables"
        ["curl"]="curl"
        ["wget"]="wget"
        ["bc"]="bc"
    )
fi

echo -e "${BLUE}Installing dependencies...${NC}"

# Process each package from requirements.txt
while read package; do
    # Skip empty lines and comments
    if [[ -z "$package" || "$package" =~ ^[[:space:]]*$ || "$package" =~ ^# ]]; then
        continue
    fi
    
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        # For Arch Linux, handle package mapping
        if [[ -n "${ARCH_PKG_MAP[$package]}" ]]; then
            mapped_package="${ARCH_PKG_MAP[$package]}"
            echo -e "${BLUE}Installing: $package (mapped to ${mapped_package})${NC}"
        else
            mapped_package="$package"
            echo -e "${YELLOW}No mapping found for $package, using original name${NC}"
        fi
        
        # Check if package is already installed
        if pacman -Qi "$mapped_package" &>/dev/null; then
            echo -e "${GREEN}Package $mapped_package is already installed${NC}"
        else
            echo -e "${BLUE}Installing package: $mapped_package${NC}"
            if eval "$INSTALL_CMD $mapped_package"; then
                echo -e "${GREEN}Successfully installed $mapped_package${NC}"
            else
                echo -e "${RED}Failed to install $mapped_package${NC}"
                failed_packages+=("$package -> $mapped_package")
            fi
        fi
    else
        # For other package managers
        echo -e "${BLUE}Installing package: $package${NC}"
        if eval "$INSTALL_CMD $package"; then
            echo -e "${GREEN}Successfully installed $package${NC}"
        else
            echo -e "${RED}Failed to install $package${NC}"
            failed_packages+=("$package")
        fi
    fi
done < requirements.txt

# Make script executable
echo -e "${BLUE}Setting up executable...${NC}"
chmod +x wifi_troubleshooter.sh

# Create symbolic link
ln -sf "$(pwd)/wifi_troubleshooter.sh" /usr/local/bin/wifi-diagnostics

# Report any failed packages
if [ ${#failed_packages[@]} -ne 0 ]; then
    echo -e "${YELLOW}The following packages failed to install:${NC}"
    printf '%s\n' "${failed_packages[@]}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can now run the tool by typing: ${BLUE}wifi-diagnostics${NC}"

#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Array to track failed packages
declare -a failed_packages=()

echo -e "${BLUE}Installing WiFi Diagnostics Tool...${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    UPDATE_CMD="apt update"
    INSTALL_CMD="apt install -y"
    # Package name mappings for Debian/Ubuntu
    PKG_MAP=(
        "bind-utils:dnsutils" 
        "netcat-openbsd:netcat-openbsd"
    )
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="dnf check-update"
    INSTALL_CMD="dnf install -y"
    # Package name mappings for Fedora
    PKG_MAP=(
        "dnsutils:bind-utils"
        "netcat-openbsd:netcat"
    )
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    UPDATE_CMD="yum check-update"
    INSTALL_CMD="yum install -y"
    # Package name mappings for CentOS/RHEL
    PKG_MAP=(
        "dnsutils:bind-utils"
        "netcat-openbsd:nmap-ncat"
        "dhclient:dhcp-client"
    )
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    UPDATE_CMD="pacman -Syy"
    INSTALL_CMD="pacman -S --noconfirm --needed"
    
    # Define a direct mapping for Arch Linux packages
    declare -A ARCH_PKG_MAP=(
        ["python3"]="python"
        ["python-pip"]="python-pip"
        ["iproute2"]="iproute2"
        ["wireless-tools"]="wireless_tools"
        ["net-tools"]="net-tools"
        ["iw"]="iw"
        ["NetworkManager"]="networkmanager"
        ["wpa_supplicant"]="wpa_supplicant"
        ["dhcpcd"]="dhcpcd"
        ["dhclient"]="dhclient"
        ["pciutils"]="pciutils"
        ["rfkill"]="util-linux"
        ["lshw"]="lshw"
        ["speedtest-cli"]="speedtest-cli"
        ["nmap"]="nmap"
        ["tcpdump"]="tcpdump"
        ["netcat-openbsd"]="openbsd-netcat"
        ["bind-utils"]="bind-tools"
        ["dnsutils"]="bind-tools"
        ["iptables"]="iptables"
        ["curl"]="curl"
        ["wget"]="wget"
        ["bc"]="bc"
    )
else
    echo -e "${RED}Unsupported package manager. Please install dependencies manually.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected package manager: ${PKG_MANAGER}${NC}"

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
eval $UPDATE_CMD

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"

# Process each package from requirements.txt
while read package; do
    # Skip empty package names
    if [[ -z "$package" || "$package" =~ ^[[:space:]]*$ || "$package" =~ ^# ]]; then
        continue
    fi
    
    # Trim whitespace
    package=$(echo "$package" | xargs)
    
    # Skip if package is empty after trimming
    if [[ -z "$package" ]]; then
        continue
    fi
    
    # Map package names based on the package manager
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        # For Arch Linux, handle package mapping
        if [[ -n "${ARCH_PKG_MAP[$package]}" ]]; then
            mapped_package="${ARCH_PKG_MAP[$package]}"
            echo -e "${BLUE}Installing: $package (using ${mapped_package})${NC}"
        else
            mapped_package="$package"
            echo -e "${YELLOW}Using original package name: $package${NC}"
        fi
        
        # Check if package is already installed
        if pacman -Qi "$mapped_package" &>/dev/null; then
            echo -e "${GREEN}Package $mapped_package is already installed${NC}"
        else
            echo -e "${BLUE}Installing package: $mapped_package${NC}"
            eval "$INSTALL_CMD $mapped_package" || {
                echo -e "${RED}Failed to install ${mapped_package}${NC}"
                failed_packages+=("$package -> $mapped_package")
            }
        fi
    else
        # For other package managers
        mapped_package="$package"
        for mapping in "${PKG_MAP[@]}"; do
            original=$(echo $mapping | cut -d: -f1)
            mapped=$(echo $mapping | cut -d: -f2)
            if [[ "$package" == "$original" ]]; then
                mapped_package="$mapped"
                break
            fi
        done
        
        echo -e "${BLUE}Installing package: $package${NC}"
        eval "$INSTALL_CMD $mapped_package" || {
            echo -e "${RED}Failed to install ${mapped_package}${NC}"
            failed_packages+=("$package")
        }
    fi
done < requirements.txt

# Make script executable
echo -e "${BLUE}Setting up executable...${NC}"
chmod +x wifi_troubleshooter.sh

# Create symbolic link
ln -sf "$(pwd)/wifi_troubleshooter.sh" /usr/local/bin/wifi-diagnostics

# Report any failed packages
if [ ${#failed_packages[@]} -ne 0 ]; then
    echo -e "${YELLOW}The following packages failed to install:${NC}"
    printf '%s\n' "${failed_packages[@]}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can now run the tool by typing: ${BLUE}wifi-diagnostics${NC}"
