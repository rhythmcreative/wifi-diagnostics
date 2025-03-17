#!/bin/bash

# WiFi Troubleshooter Script
# Provides comprehensive diagnostics for WiFi connectivity issues

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}│ $1${NC}$(printf '%*s' $((51 - ${#1})) "")${BOLD}${BLUE}│${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}\n"
}

# Function to print success messages
print_success() {
    echo -e "${BOLD}${GREEN}✓ SUCCESS:${NC} ${GREEN}$1${NC}"
}

# Function to print warning messages
print_warning() {
    echo -e "${BOLD}${YELLOW}⚠ WARNING:${NC} ${YELLOW}$1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${BOLD}${RED}✗ ERROR:${NC} ${RED}$1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${BOLD}${PURPLE}ℹ INFO:${NC} ${PURPLE}$1${NC}"
}

# Function to write debug logs to both stdout and a log file
log_debug() {
    local message="[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo -e "${YELLOW}$message${NC}"
    
    # Create log directory if it doesn't exist
    local log_dir="/tmp/wifi_troubleshooter_logs"
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi
    
    # Write to log file
    echo "$message" >> "$log_dir/debug_$(date '+%Y%m%d').log"
}

# Function to log errors
log_error() {
    local message="[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo -e "${RED}$message${NC}"
    
    # Create log directory if it doesn't exist
    local log_dir="/tmp/wifi_troubleshooter_logs"
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi
    
    # Write to log file
    echo "$message" >> "$log_dir/debug_$(date '+%Y%m%d').log"
}

# Function to execute command with error logging
execute_cmd() {
    local cmd="$1"
    local error_msg="$2"
    
    log_debug "Executing: $cmd"
    
    # Execute the command and capture both stdout and stderr
    local output
    output=$(eval "$cmd" 2>&1)
    local status=$?
    
    if [ $status -ne 0 ]; then
        log_error "$error_msg"
        log_error "Command output: $output"
        log_error "Exit code: $status"
        return $status
    fi
    
    log_debug "Command executed successfully."
    echo "$output"
    return 0
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to display the menu
display_menu() {
    clear
    echo -e "${BOLD}${CYAN}██╗    ██╗██╗███████╗██╗    ██████╗ ███████╗██████╗  █████╗ ██╗██████╗ ███████╗${NC}"
    echo -e "${BOLD}${CYAN}██║    ██║██║██╔════╝██║    ██╔══██╗██╔════╝██╔══██╗██╔══██╗██║██╔══██╗██╔════╝${NC}"
    echo -e "${BOLD}${CYAN}██║ █╗ ██║██║█████╗  ██║    ██████╔╝█████╗  ██████╔╝███████║██║██████╔╝███████╗${NC}"
    echo -e "${BOLD}${CYAN}██║███╗██║██║██╔══╝  ██║    ██╔══██╗██╔══╝  ██╔═══╝ ██╔══██║██║██╔══██╗╚════██║${NC}"
    echo -e "${BOLD}${CYAN}╚███╔███╔╝██║██║     ██║    ██║  ██║███████╗██║     ██║  ██║██║██║  ██║███████║${NC}"
    echo -e "${BOLD}${CYAN} ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝${NC}"
    echo
    echo -e "${BOLD}${YELLOW}        ✧ ✧ ✧  A comprehensive WiFi diagnostic tool  ✧ ✧ ✧${NC}"
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}│                         MAIN MENU                          │${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "  ${BOLD}${CYAN}[1]${NC} ⟹  ${BOLD}Scan WiFi Networks${NC}"
    echo -e "  ${BOLD}${CYAN}[2]${NC} ⟹  ${BOLD}Check Connection Status${NC}"
    echo -e "  ${BOLD}${CYAN}[3]${NC} ⟹  ${BOLD}Check Signal Strength${NC}"
    echo -e "  ${BOLD}${CYAN}[4]${NC} ⟹  ${BOLD}Test Internet Connectivity${NC}"
    echo -e "  ${BOLD}${CYAN}[5]${NC} ⟹  ${BOLD}Full Diagnostic${NC}"
    echo -e "  ${BOLD}${CYAN}[6]${NC} ⟹  ${BOLD}Advanced Tools${NC}"
    echo -e "  ${BOLD}${CYAN}[7]${NC} ⟹  ${BOLD}Exit${NC}"
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e -n "  ${BOLD}Enter your choice [1-7]:${NC} "
}
# Function to handle errors and return to menu
handle_error() {
    local error_message=$1
    print_error "$error_message"
    echo
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    return 1
}

# Function to run the full diagnostic
run_full_diagnostic() {
    display_menu
    
    # Step 1: Identify WiFi interfaces
    identify_wifi_interfaces || return 1
    
    # Step 2: Check if the WiFi interface is enabled and not blocked
    check_wifi_status || return 1
    
    # Step 3: Scan and display available networks
    scan_wifi_networks || return 1
    
    # Step 4: Check current connection status
    check_connection_status || return 1
    
    # Step 5: Check signal strength
    check_signal_strength || return 1
    
    # Step 6: Test internet connectivity
    check_internet_connectivity || return 1
    
    # Step 7: Provide recommendations
    provide_recommendations || return 1
    
    print_header "Troubleshooting Complete"
    print_header "Troubleshooting Complete"
    
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    return 0
}

# Function for advanced tools
advanced_tools() {
    clear
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}│                    ADVANCED WIFI TOOLS                     │${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "  ${BOLD}${CYAN}[1]${NC}  ⟹  ${BOLD}Check WiFi Driver Details${NC}"
    echo -e "  ${BOLD}${CYAN}[2]${NC}  ⟹  ${BOLD}View Network Interface Configuration${NC}"
    echo -e "  ${BOLD}${CYAN}[3]${NC}  ⟹  ${BOLD}Monitor WiFi Traffic${NC}"
    echo -e "  ${BOLD}${CYAN}[4]${NC}  ⟹  ${BOLD}Start/Restart NetworkManager${NC}"
    echo -e "  ${BOLD}${CYAN}[5]${NC}  ⟹  ${BOLD}DNS Configuration and Testing${NC}"
    echo -e "  ${BOLD}${CYAN}[6]${NC}  ⟹  ${BOLD}Network Speed Test${NC}"
    echo -e "  ${BOLD}${CYAN}[7]${NC}  ⟹  ${BOLD}Firewall Status${NC}"
    echo -e "  ${BOLD}${CYAN}[8]${NC}  ⟹  ${BOLD}Network Port Scanner${NC}"
    echo -e "  ${BOLD}${CYAN}[9]${NC}  ⟹  ${BOLD}Network Logs Viewer${NC}"
    echo -e "  ${BOLD}${CYAN}[10]${NC} ⟹  ${BOLD}Backup Network Config${NC}"
    echo -e "  ${BOLD}${CYAN}[11]${NC} ⟹  ${BOLD}Network Services Status${NC}"
    echo -e "  ${BOLD}${CYAN}[12]${NC} ⟹  ${BOLD}Back to Main Menu${NC}"
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -n "  ${BOLD}Enter your choice [1-12]:${NC} "
    read -r advanced_choice
    case $advanced_choice in
        1)
            clear
            print_header "WiFi Driver Details"
            
            if command_exists lshw; then
                echo "Driver information:"
                sudo lshw -C network | grep -E "driver|description|product|vendor" | sed 's/^/  /'
            elif command_exists lspci; then
                echo "Network device information:"
                lspci | grep -i network | sed 's/^/  /'
            else
                print_error "Neither lshw nor lspci commands are available."
                print_info "Consider installing lshw or pciutils packages."
            fi
            
            echo
            if command_exists modinfo; then
                # Try to find the WiFi driver module name
                DRIVER_MODULE=$(ethtool -i $WIFI_INTERFACE 2>/dev/null | grep driver | cut -d: -f2 | tr -d ' ')
                
                if [[ -n "$DRIVER_MODULE" ]]; then
                    echo "Driver module information for $DRIVER_MODULE:"
                    modinfo $DRIVER_MODULE | grep -E "filename|version|author|description" | sed 's/^/  /'
                else
                    print_warning "Could not determine WiFi driver module."
                fi
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        2)
            clear
            print_header "Network Interface Configuration"
            
            if command_exists ifconfig; then
                echo "Interface configuration for $WIFI_INTERFACE:"
                ifconfig $WIFI_INTERFACE | sed 's/^/  /'
            elif command_exists ip; then
                echo "Interface configuration for $WIFI_INTERFACE:"
                ip addr show $WIFI_INTERFACE | sed 's/^/  /'
            else
                print_error "Neither ifconfig nor ip commands are available."
            fi
            
            echo -e "\nRouting information:"
            if command_exists route; then
                route -n | sed 's/^/  /'
            elif command_exists ip; then
                ip route | sed 's/^/  /'
            else
                print_error "Neither route nor ip commands are available."
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        3)
            clear
            print_header "WiFi Traffic Monitoring"
            
            if command_exists tcpdump; then
                print_info "Monitoring traffic on $WIFI_INTERFACE. Press Ctrl+C to stop."
                echo -e "Starting capture in 3 seconds...\n"
                sleep 3
                sudo tcpdump -i $WIFI_INTERFACE -n -c 50
            else
                print_error "The tcpdump command is not available."
                print_info "Consider installing tcpdump package for network monitoring."
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        4)
            clear
            print_header "Start/Restart NetworkManager"
            
            if command_exists systemctl; then
                print_info "Attempting to restart NetworkManager..."
                sudo systemctl restart NetworkManager
                if [ $? -eq 0 ]; then
                    print_success "NetworkManager restarted successfully!"
                else
                    print_error "Failed to restart NetworkManager. Check if the service is installed."
                fi
            else
                print_error "The systemctl command is not available."
                print_info "This system may not be using systemd. Try 'sudo service network-manager restart' instead."
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        5)
            clear
            print_header "DNS Configuration and Testing"
            
            # Check current DNS servers
            echo "Current DNS configuration:"
            if [ -f /etc/resolv.conf ]; then
                grep nameserver /etc/resolv.conf | sed 's/^/  /'
            else
                print_error "No /etc/resolv.conf file found."
            fi
            
            echo -e "\nDNS resolver test:"
            if command_exists dig; then
                echo "Testing DNS resolution with dig..."
                dig +short google.com | sed 's/^/  /'
                
                echo -e "\nTesting DNS response time:"
                dig google.com | grep "Query time" | sed 's/^/  /'
            elif command_exists nslookup; then
                echo "Testing DNS resolution with nslookup..."
                nslookup google.com | grep -E "Address|Name" | sed 's/^/  /'
            else
                print_error "Neither dig nor nslookup commands found."
                print_info "Consider installing dnsutils or bind-utils package."
            fi
            
            # DNS change option
            echo -e "\nWould you like to change your DNS servers? (y/n): "
            read -r dns_change
            if [[ "$dns_change" == "y" || "$dns_change" == "Y" ]]; then
                echo "Select DNS provider:"
                echo "1. Google DNS (8.8.8.8, 8.8.4.4)"
                echo "2. Cloudflare (1.1.1.1, 1.0.0.1)"
                echo "3. OpenDNS (208.67.222.222, 208.67.220.220)"
                echo "4. Custom DNS servers"
                echo -n "Enter your choice [1-4]: "
                read -r dns_provider
                
                case $dns_provider in
                    1)
                        dns_servers="nameserver 8.8.8.8\nnameserver 8.8.4.4"
                        ;;
                    2)
                        dns_servers="nameserver 1.1.1.1\nnameserver 1.0.0.1"
                        ;;
                    3)
                        dns_servers="nameserver 208.67.222.222\nnameserver 208.67.220.220"
                        ;;
                    4)
                        echo -n "Enter primary DNS server: "
                        read -r primary_dns
                        echo -n "Enter secondary DNS server (optional): "
                        read -r secondary_dns
                        
                        dns_servers="nameserver $primary_dns"
                        if [[ -n "$secondary_dns" ]]; then
                            dns_servers="$dns_servers\nnameserver $secondary_dns"
                        fi
                        ;;
                    *)
                        print_error "Invalid selection. DNS configuration unchanged."
                        ;;
                esac
                
                if [[ -n "$dns_servers" ]]; then
                    if [ "$(id -u)" -eq 0 ]; then
                        echo -e "$dns_servers" | sudo tee /etc/resolv.conf > /dev/null
                        print_success "DNS servers updated successfully."
                    else
                        print_error "Root privileges required to modify DNS configuration."
                        print_info "Run the script with sudo to make DNS changes."
                    fi
                fi
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        6)
            clear
            print_header "Network Speed Test"
            
            # Check if speedtest-cli is installed
            if command_exists speedtest-cli; then
                print_info "Running internet speed test (may take a minute)..."
                speedtest_result=$(speedtest-cli --simple 2>&1)
                if [[ $? -eq 0 ]]; then
                    echo -e "\nSpeed Test Results:"
                    echo "$speedtest_result" | sed 's/^/  /'
                else
                    print_error "Speed test failed."
                    echo "$speedtest_result" | sed 's/^/  /'
                fi
            else
                # Alternative speed test using curl/wget
                print_info "speedtest-cli not found. Using alternative methods."
                echo -e "\nTesting download speed..."
                
                # Create a temporary file
                tmp_file="/tmp/speedtest_$$.tmp"
                
                # Choose a test file to download
                test_url="http://speedtest.tele2.net/10MB.zip"
                
                # Download the file and measure time
                if command_exists curl; then
                    start_time=$(date +%s.%N)
                    curl -s -o "$tmp_file" "$test_url"
                    status=$?
                elif command_exists wget; then
                    start_time=$(date +%s.%N)
                    wget -q -O "$tmp_file" "$test_url"
                    status=$?
                else
                    print_error "Neither curl nor wget found. Cannot perform speed test."
                    status=1
                fi
                
                if [[ $status -eq 0 ]]; then
                    end_time=$(date +%s.%N)
                    duration=$(echo "$end_time - $start_time" | bc)
                    filesize=$(ls -l "$tmp_file" | awk '{print $5}')
                    speed=$(echo "scale=2; $filesize / $duration / 1024 / 1024 * 8" | bc)
                    
                    print_success "Download speed: ${speed} Mbps"
                    
                    # Cleanup
                    rm -f "$tmp_file"
                else
                    print_error "Download test failed."
                fi
                
                print_info "Consider installing speedtest-cli for more accurate tests:"
                echo "  sudo apt-get install speedtest-cli   # Debian/Ubuntu"
                echo "  sudo yum install speedtest-cli       # CentOS/RHEL"
                echo "  pip install speedtest-cli            # Using pip"
            fi
            
            # Latency test
            echo -e "\nTesting latency to common servers:"
            targets=("google.com" "cloudflare.com" "amazon.com")
            
            for target in "${targets[@]}"; do
                if command_exists ping; then
                    echo -n "  $target: "
                    ping_result=$(ping -c 4 -q "$target" 2>&1)
                    if [[ $? -eq 0 ]]; then
                        avg_time=$(echo "$ping_result" | grep "avg" | cut -d '/' -f 5)
                        echo "${avg_time}ms"
                    else
                        echo "Failed"
                    fi
                fi
            done
            
            wait_for_user_input
            advanced_tools
            ;;
        7)
            clear
            print_header "Firewall Status"
            
            # Check for different firewall tools
            if command_exists ufw; then
                echo "UFW Firewall Status:"
                sudo ufw status | sed 's/^/  /'
            elif command_exists firewall-cmd; then
                echo "FirewallD Status:"
                sudo firewall-cmd --state | sed 's/^/  /'
                echo -e "\nFirewallD Active Zones:"
                sudo firewall-cmd --list-all | sed 's/^/  /'
            elif command_exists iptables; then
                echo "IPTables Rules:"
                sudo iptables -L -n | sed 's/^/  /'
            else
                print_warning "No recognized firewall management tool found."
            fi
            
            # Check if specific ports are open/closed
            echo -e "\nWould you like to check if specific ports are open? (y/n): "
            read -r check_ports
            if [[ "$check_ports" == "y" || "$check_ports" == "Y" ]]; then
                echo -n "Enter port to check: "
                read -r port_to_check
                
                if [[ -n "$port_to_check" ]]; then
                    if command_exists nc; then
                        echo "Checking if port $port_to_check is open on localhost..."
                        if nc -z -v -w 3 localhost "$port_to_check" 2>&1 | grep -q "succeeded"; then
                            print_success "Port $port_to_check is OPEN on localhost"
                        else
                            print_warning "Port $port_to_check is CLOSED on localhost"
                        fi
                    else
                        print_error "The 'nc' command is not available."
                        print_info "Consider installing netcat package for port testing."
                    fi
                fi
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        8)
            clear
            print_header "Network Port Scanner"
            
            # Check if necessary tools are installed
            if ! command_exists nmap; then
                print_error "nmap is not installed."
                print_info "Install nmap for port scanning: sudo apt install nmap (Debian/Ubuntu)"
                print_info "                            or: sudo yum install nmap (CentOS/RHEL)"
                wait_for_user_input
                advanced_tools
                return
            fi
            
            # Get the local network range
            local_ip=$(ip addr show $WIFI_INTERFACE | grep -oP 'inet \K[\d.]+')
            local_network=$(echo $local_ip | cut -d. -f1-3)
            
            # Options for scanning
            echo "Port Scanning Options:"
            echo "1. Quick scan of local machine"
            echo "2. Scan specific IP address"
            echo "3. Scan local network for devices"
            echo -n "Enter your choice [1-3]: "
            read -r scan_choice
            
            case $scan_choice in
                1)
                    print_info "Scanning common ports on localhost..."
                    sudo nmap -T4 -F localhost
                    ;;
                2)
                    echo -n "Enter IP address to scan: "
                    read -r target_ip
                    if [[ -n "$target_ip" ]]; then
                        print_info "Scanning common ports on $target_ip..."
                        sudo nmap -T4 -F "$target_ip"
                    else
                        print_error "No IP address provided."
                    fi
                    ;;
                3)
                    if [[ -n "$local_network" ]]; then
                        print_info "Scanning for devices on local network ($local_network.0/24)..."
                        print_info "This may take a minute..."
                        sudo nmap -T4 -sn "$local_network.0/24"
                    else
                        print_error "Could not determine local network address."
                        echo -n "Enter network range to scan (e.g., 192.168.1.0/24): "
                        read -r network_range
                        if [[ -n "$network_range" ]]; then
                            print_info "Scanning for devices on $network_range..."
                            sudo nmap -T4 -sn "$network_range"
                        fi
                    fi
                    ;;
                *)
                    print_error "Invalid option."
                    ;;
            esac
            
            wait_for_user_input
            advanced_tools
            ;;
        9)
            clear
            print_header "Network Logs Viewer"
            
            # Define log files to check
            log_files=(
                "/var/log/syslog"
                "/var/log/messages"
                "/var/log/dmesg"
                "/var/log/kern.log"
                "/var/log/NetworkManager"
            )
            
            # Let user select which log to view
            echo "Select a log to view:"
            valid_logs=()
            
            for i in "${!log_files[@]}"; do
                if [ -f "${log_files[$i]}" ]; then
                    valid_logs+=("${log_files[$i]}")
                    echo "$((i+1)). ${log_files[$i]}"
                fi
            done
            
            if [ ${#valid_logs[@]} -eq 0 ]; then
                print_error "No relevant network log files found."
                
                # Try journalctl as an alternative
                if command_exists journalctl; then
                    print_info "Trying to use journalctl instead..."
                    echo "1. Network-related messages"
                    echo "2. NetworkManager logs"
                    echo "3. DHCP client logs"
                    echo "4. Kernel network messages"
                    echo -n "Enter your choice [1-4]: "
                    read -r journal_choice
                    
                    case $journal_choice in
                        1)
                            journalctl | grep -i "network\|wifi\|wireless\|inet" | tail -n 50
                            ;;
                        2)
                            journalctl -u NetworkManager | tail -n 50
                            ;;
                        3)
                            journalctl | grep -i "dhclient\|dhcp" | tail -n 50
                            ;;
                        4)
                            journalctl -k | grep -i "wifi\|wlan\|eth\|net:" | tail -n 50
                            ;;
                        *)
                            print_error "Invalid option."
                            ;;
                    esac
                else
                    print_error "journalctl command not found. Cannot show logs."
                fi
            else
                echo -n "Enter your choice [1-${#valid_logs[@]}]: "
                read -r log_choice
                
                if [[ "$log_choice" =~ ^[0-9]+$ ]] && [[ "$log_choice" -ge 1 ]] && [[ "$log_choice" -le ${#valid_logs[@]} ]]; then
                    selected_log="${valid_logs[$((log_choice-1))]}"
                    
                    echo -e "\nShowing last 50 lines of $selected_log with network-related entries:"
                    if [ "$(id -u)" -eq 0 ]; then
                        grep -i "network\|wifi\|wireless\|wlan\|eth\|inet\|connection" "$selected_log" | tail -n 50 | sed 's/^/  /'
                    else
                        sudo grep -i "network\|wifi\|wireless\|wlan\|eth\|inet\|connection" "$selected_log" | tail -n 50 | sed 's/^/  /'
                    fi
                    
                    echo -e "\nWould you like to see the full log? (y/n): "
                    read -r view_full
                    if [[ "$view_full" == "y" || "$view_full" == "Y" ]]; then
                        if command_exists less; then
                            sudo less "$selected_log"
                        else
                            sudo more "$selected_log"
                        fi
                    fi
                else
                    print_error "Invalid selection."
                fi
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        10)
            clear
            print_header "Network Configuration Backup"
            
            # Determine backup directory
            backup_dir="$HOME/network_config_backup"
            backup_file="network_config_$(date +%Y%m%d_%H%M%S).tar.gz"
            
            # Create backup directory if it doesn't exist
            if [ ! -d "$backup_dir" ]; then
                mkdir -p "$backup_dir"
                print_info "Created backup directory: $backup_dir"
            fi
            
            print_info "Backing up network configuration to $backup_dir/$backup_file"
            
            # Create a temporary directory for collecting configuration files
            temp_dir=$(mktemp -d)
            
            # List of files and commands to back up
            echo "Collecting network configuration files..."
            
            # Network interfaces configuration
            if [ -f /etc/network/interfaces ]; then
                cp /etc/network/interfaces "$temp_dir/" 2>/dev/null && print_success "Backed up /etc/network/interfaces"
            fi
            
            # NetworkManager configurations
            if [ -d /etc/NetworkManager ]; then
                mkdir -p "$temp_dir/NetworkManager"
                cp -r /etc/NetworkManager/system-connections "$temp_dir/NetworkManager/" 2>/dev/null && print_success "Backed up NetworkManager connections"
            fi
            
            # DNS configuration
            if [ -f /etc/resolv.conf ]; then
                cp /etc/resolv.conf "$temp_dir/" 2>/dev/null && print_success "Backed up DNS configuration"
            fi
            
            # Hosts file
            if [ -f /etc/hosts ]; then
                cp /etc/hosts "$temp_dir/" 2>/dev/null && print_success "Backed up hosts file"
            fi
            
            # DHCP configuration
            if [ -f /etc/dhcp/dhclient.conf ]; then
                cp /etc/dhcp/dhclient.conf "$temp_dir/" 2>/dev/null && print_success "Backed up DHCP client configuration"
            fi
            
            # Collect output from network commands
            if command_exists ip; then
                ip addr > "$temp_dir/ip_addr.txt" 2>/dev/null && print_success "Saved IP address configuration"
                ip route > "$temp_dir/ip_route.txt" 2>/dev/null && print_success "Saved IP routing table"
            fi
            
            if command_exists iwconfig; then
                iwconfig > "$temp_dir/iwconfig.txt" 2>/dev/null && print_success "Saved wireless interface configuration"
            fi
            
            if command_exists nmcli && [ -x "$(command -v nmcli)" ]; then
                nmcli connection show > "$temp_dir/nmcli_connections.txt" 2>/dev/null && print_success "Saved NetworkManager connections"
                nmcli device status > "$temp_dir/nmcli_devices.txt" 2>/dev/null && print_success "Saved NetworkManager device status"
            fi
            
            # Create archive
            if tar -czf "$backup_dir/$backup_file" -C "$temp_dir" . 2>/dev/null; then
                print_success "Successfully created network configuration backup at: $backup_dir/$backup_file"
            else
                print_error "Failed to create backup archive."
            fi
            
            # Clean up
            rm -rf "$temp_dir"
            
            # Restore option
            echo -e "\nWould you like to restore a previous backup? (y/n): "
            read -r restore_choice
            if [[ "$restore_choice" == "y" || "$restore_choice" == "Y" ]]; then
                # List available backups
                backups=("$backup_dir"/*.tar.gz)
                
                if [ ${#backups[@]} -eq 0 ] || [ ! -f "${backups[0]}" ]; then
                    print_error "No backup files found in $backup_dir."
                else
                    echo -e "\nAvailable backups:"
                    for i in "${!backups[@]}"; do
                        echo "$((i+1)). $(basename "${backups[$i]}") ($(date -r "${backups[$i]}" "+%Y-%m-%d %H:%M:%S"))"
                    done
                    
                    echo -n "Enter backup number to restore (or 0 to cancel): "
                    read -r backup_num
                    
                    if [[ "$backup_num" =~ ^[0-9]+$ ]] && [ "$backup_num" -ge 1 ] && [ "$backup_num" -le ${#backups[@]} ]; then
                        selected_backup="${backups[$((backup_num-1))]}"
                        
                        print_warning "Restoring configuration from backup may disrupt current network connections."
                        echo -n "Are you sure you want to continue? (y/n): "
                        read -r confirm
                        
                        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                            # Create a temporary directory for extraction
                            restore_temp=$(mktemp -d)
                            
                            # Extract the backup
                            if tar -xzf "$selected_backup" -C "$restore_temp"; then
                                print_success "Extracted backup files for restoration."
                                
                                # Restore NetworkManager connections if present
                                if [ -d "$restore_temp/NetworkManager/system-connections" ]; then
                                    sudo cp -r "$restore_temp/NetworkManager/system-connections" /etc/NetworkManager/ 2>/dev/null && print_success "Restored NetworkManager connections"
                                fi
                                
                                # Restart NetworkManager to apply changes
                                if command_exists systemctl; then
                                    sudo systemctl restart NetworkManager 2>/dev/null && print_success "Restarted NetworkManager to apply changes"
                                elif command_exists service; then
                                    sudo service network-manager restart 2>/dev/null && print_success "Restarted network-manager to apply changes"
                                fi
                                
                                print_info "Configuration restoration completed. Some settings may require a system restart."
                            else
                                print_error "Failed to extract backup archive."
                            fi
                            
                            # Clean up
                            rm -rf "$restore_temp"
                        else
                            print_info "Restoration cancelled."
                        fi
                    elif [ "$backup_num" -eq 0 ]; then
                        print_info "Restoration cancelled."
                    else
                        print_error "Invalid backup selection."
                    fi
                fi
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        11)
            clear
            print_header "Network Services Status"
            
            # Define common network services to check
            network_services=(
                "NetworkManager"
                "network-manager"
                "networking"
                "systemd-networkd"
                "wpa_supplicant"
                "dhcpcd"
                "dhclient"
                "avahi-daemon"
                "ssh"
                "firewalld"
                "ufw"
                "dnsmasq"
                "resolved"
                "systemd-resolved"
                "bind9"
                "named"
            )
            
            # Check which service management system is in use
            if command_exists systemctl; then
                print_info "Checking status of network-related services..."
                
                for service in "${network_services[@]}"; do
                    # Check if service exists before querying status
                    if systemctl list-unit-files "${service}.service" &>/dev/null; then
                        status=$(systemctl is-active "$service" 2>/dev/null)
                        enabled=$(systemctl is-enabled "$service" 2>/dev/null || echo "unknown")
                        
                        if [ "$status" = "active" ]; then
                            print_success "$service is running (enabled: $enabled)"
                        else
                            print_warning "$service is $status (enabled: $enabled)"
                        fi
                    fi
                done
                
                # Check for any failed network-related services
                echo -e "\nChecking for failed network-related services:"
                failed_services=$(systemctl --failed | grep -E "Network|network|wifi|DHCP|dhcp|wpa|wifi|ethernet" | sed 's/^/  /')
                
                if [ -n "$failed_services" ]; then
                    print_error "Found failed network-related services:"
                    echo "$failed_services"
                else
                    print_success "No failed network-related services found."
                fi
                
                # Option to restart a service
                echo -e "\nWould you like to restart a network service? (y/n): "
                read -r restart_service
                if [[ "$restart_service" == "y" || "$restart_service" == "Y" ]]; then
                    echo -n "Enter service name to restart: "
                    read -r service_name
                    
                    if [ -n "$service_name" ]; then
                        print_info "Attempting to restart $service_name..."
                        
                        if sudo systemctl restart "$service_name"; then
                            print_success "Service $service_name restarted successfully."
                        else
                            print_error "Failed to restart $service_name. Check if the service name is correct."
                        fi
                    fi
                fi
                
            elif command_exists service; then
                print_info "Checking status of network-related services using legacy service command..."
                
                for service in "${network_services[@]}"; do
                    # Use service command to check status
                    status=$(service "$service" status 2>/dev/null || echo "unknown")
                    
                    if echo "$status" | grep -qE "running|active"; then
                        print_success "$service appears to be running"
                    elif echo "$status" | grep -qE "stopped|inactive|unknown"; then
                        print_warning "$service appears to be stopped or not installed"
                    fi
                done
                
                # Option to restart a service
                echo -e "\nWould you like to restart a network service? (y/n): "
                read -r restart_service
                if [[ "$restart_service" == "y" || "$restart_service" == "Y" ]]; then
                    echo -n "Enter service name to restart: "
                    read -r service_name
                    
                    if [ -n "$service_name" ]; then
                        print_info "Attempting to restart $service_name..."
                        
                        if sudo service "$service_name" restart; then
                            print_success "Service $service_name restart initiated."
                        else
                            print_error "Failed to restart $service_name. Check if the service name is correct."
                        fi
                    fi
                fi
            else
                print_error "No supported service management system found (systemctl or service)."
                print_info "Cannot determine network service status on this system."
            fi
            
            wait_for_user_input
            advanced_tools
            ;;
        12)
            return 0
            ;;
        *)
            print_error "Invalid option. Please select a number between 1 and 12."
            wait_for_user_input
            advanced_tools
            ;;
    esac
}

# (Removed duplicate display_banner function)

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}│                       ROOT PRIVILEGES                      │${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    print_warning "This script is not running as root. Some commands may fail."
    print_info "Consider running with sudo for complete diagnostics."
    echo
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
fi

# Helper functions to determine WiFi security type and format connection commands
determine_wifi_security() {
    local security="$1"
    
    if [[ "$security" == *"WPA3"* ]]; then
        echo "WPA-PSK:WPA3"
    elif [[ "$security" == *"WPA2"* ]]; then
        echo "WPA-PSK:WPA2"
    elif [[ "$security" == *"WPA"* ]]; then
        echo "WPA-PSK:WPA"
    elif [[ "$security" == *"WEP"* ]]; then
        echo "NONE:WEP"
    elif [[ -z "$security" || "$security" == "Open" ]]; then
        echo "NONE:Open"
    else
        echo "WPA-PSK:Unknown"
    fi
}

format_connection_command() {
    local ssid="$1"
    local password="$2"
    local auth_type="$3"
    
    if command_exists nmcli; then
        case "$auth_type" in
            "WPA3"|"WPA2"|"WPA")
                echo "sudo nmcli device wifi connect \"$ssid\" password \"$password\""
                ;;
            "WEP")
                echo "sudo nmcli device wifi connect \"$ssid\" password \"$password\" wep-key-type key"
                ;;
            "Open")
                echo "sudo nmcli device wifi connect \"$ssid\""
                ;;
            *)
                # Default to WPA as a fallback
                echo "sudo nmcli device wifi connect \"$ssid\" password \"$password\""
                ;;
        esac
    else
        echo "echo 'NetworkManager not available, using wpa_supplicant method instead'"
    fi
}
# Function to identify WiFi interfaces
identify_wifi_interfaces() {
    print_header "Identifying WiFi Interfaces"
    
    if command_exists ip; then
        INTERFACES=$(ip -br link | grep -v "lo" | awk '{print $1}')
        # Also get interfaces from iwconfig to catch all WiFi interfaces
        INTERFACES="$INTERFACES $(iwconfig 2>/dev/null | grep IEEE | cut -d' ' -f1)"
        # Make INTERFACES unique
        INTERFACES=$(echo "$INTERFACES" | tr ' ' '\n' | sort -u)
        WIFI_INTERFACES=()
        
        for interface in $INTERFACES; do
            if [ -d "/sys/class/net/$interface/wireless" ] || [ -L "/sys/class/net/$interface/phy80211" ]; then
                WIFI_INTERFACES+=("$interface")
                print_success "Found WiFi interface: $interface"
            fi
        done
        
        if [ ${#WIFI_INTERFACES[@]} -eq 0 ]; then
            print_error "No WiFi interfaces found!"
            print_info "Check if your WiFi hardware is properly connected or if drivers are installed."
            return 1
        fi
        
        # If multiple interfaces found, ask user to select one
        if [ ${#WIFI_INTERFACES[@]} -gt 1 ]; then
            echo -e "\nMultiple WiFi interfaces found. Please select one:"
            select WIFI_INTERFACE in "${WIFI_INTERFACES[@]}"; do
                if [ -n "$WIFI_INTERFACE" ]; then
                    break
                fi
                echo "Invalid selection. Please try again."
            done
        else
            WIFI_INTERFACE=${WIFI_INTERFACES[0]}
        fi
        
        echo -e "\nUsing WiFi interface: ${GREEN}$WIFI_INTERFACE${NC}"
    else
        print_error "The 'ip' command is not available. Please install the 'iproute2' package."
        exit 1
    fi
}

# Check if WiFi interface is enabled
check_wifi_status() {
    print_header "Checking WiFi Status"
    
    # Check if interface exists and is up
    if ip link show $WIFI_INTERFACE &> /dev/null; then
        LINK_STATE=$(ip link show $WIFI_INTERFACE | grep -o "state [A-Z]*" | cut -d ' ' -f 2)
        
        if [ "$LINK_STATE" == "UP" ]; then
            print_success "Interface $WIFI_INTERFACE is UP"
        else
            print_error "Interface $WIFI_INTERFACE is DOWN"
            print_info "Try bringing it up with: sudo ip link set $WIFI_INTERFACE up"
            
            # Attempt to bring the interface up if running as root
            if [ "$(id -u)" -eq 0 ]; then
                echo -e "\nAttempting to bring interface up..."
                ip link set $WIFI_INTERFACE up
                sleep 2
                
                # Check if it worked
                if [ "$(ip link show $WIFI_INTERFACE | grep -o "state [A-Z]*" | cut -d ' ' -f 2)" == "UP" ]; then
                    print_success "Successfully brought interface $WIFI_INTERFACE up"
                else
                    print_error "Failed to bring interface up. This might be a hardware issue."
                    print_info "Try toggling the hardware WiFi switch if your device has one."
                fi
            fi
        fi
    else
        print_error "WiFi interface $WIFI_INTERFACE does not exist"
        identify_wifi_interfaces
    fi
    
    # Check if WiFi is soft-blocked or hard-blocked
    if command_exists rfkill; then
        echo -e "\nChecking for WiFi blocks:"
        RFKILL_INFO=$(rfkill list | grep -A 2 $WIFI_INTERFACE 2>/dev/null)
        
        if [[ -z "$RFKILL_INFO" ]]; then
            RFKILL_INFO=$(rfkill list | grep -A 2 "Wireless" 2>/dev/null)
        fi
        
        if [[ -n "$RFKILL_INFO" ]]; then
            if echo "$RFKILL_INFO" | grep -q "Soft blocked: yes"; then
                print_error "WiFi is soft-blocked"
                print_info "Unblock it with: sudo rfkill unblock wifi"
                
                # Attempt to unblock if running as root
                if [ "$(id -u)" -eq 0 ]; then
                    echo -e "\nAttempting to unblock WiFi..."
                    rfkill unblock wifi
                    print_success "WiFi unblocked"
                fi
            else
                print_success "WiFi is not soft-blocked"
            fi
            
            if echo "$RFKILL_INFO" | grep -q "Hard blocked: yes"; then
                print_error "WiFi is hard-blocked"
                print_info "This typically means the physical WiFi switch on your device is turned off."
                print_info "Turn on the physical switch to enable WiFi."
            else
                print_success "WiFi is not hard-blocked"
            fi
        else
            print_info "No rfkill information found for WiFi"
        fi
    else
        print_info "rfkill command not found. Cannot check for hardware/software blocks."
    fi
}

# Scan and display available networks
scan_wifi_networks() {
    print_header "Scanning for WiFi Networks"
    
    # Check if WiFi interface is defined
    if [ -z "$WIFI_INTERFACE" ]; then
        handle_error "Failed to identify WiFi interfaces."
        return 1
    fi
    if ! ip link show $WIFI_INTERFACE | grep -q "state UP"; then
        print_warning "WiFi interface $WIFI_INTERFACE is not UP."
        print_info "Attempting to bring it up..."
        if [ "$(id -u)" -eq 0 ]; then
            ip link set $WIFI_INTERFACE up
            sleep 2
            if ! ip link show $WIFI_INTERFACE | grep -q "state UP"; then
                print_error "Failed to bring interface up."
                return 1
            fi
        fi
    fi
    
    if command_exists iwlist; then
        echo "Scanning for networks..."
        SCAN_RESULTS=$(sudo iwlist $WIFI_INTERFACE scan 2>/dev/null | grep -E "ESSID|Quality|Encryption|Channel")
        
        if [[ -n "$SCAN_RESULTS" ]]; then
            # Parse and display networks in a more readable format
            echo -e "\nAvailable networks:"
            echo -e "${BLUE}SSID                     | Channel | Signal      | Security${NC}"
            echo -e "-----------------------------------------------------------"
            
            current_essid=""
            current_channel=""
            current_quality=""
            current_security=""
            
            while IFS= read -r line; do
                if [[ $line == *"ESSID"* ]]; then
                    # If we have a complete network, print it
                    if [[ -n "$current_essid" && -n "$current_channel" && -n "$current_quality" ]]; then
                        # Remove escape sequences from display
                        clean_essid=$(echo "$current_essid" | sed 's/\\x[0-9a-fA-F][0-9a-fA-F]//g' | tr -d '\r\n')
                        printf "%-25s | %-7s | %-10s | %s\n" "$clean_essid" "$current_channel" "$current_quality" "$current_security"
                    fi
                    
                    # Start a new network
                    current_essid=$(echo "$line" | sed 's/.*ESSID:"\(.*\)".*/\1/')
                    current_channel=""
                    current_quality=""
                    current_security=""
                    
                elif [[ $line == *"Channel"* ]]; then
                    current_channel=$(echo "$line" | sed 's/.*Channel:\(.*\).*/\1/' | tr -d ' ')
                    
                elif [[ $line == *"Quality"* ]]; then
                    quality_raw=$(echo "$line" | sed 's/.*Quality=\([0-9]*\/[0-9]*\).*/\1/')
                    signal_level=$(echo "$line" | sed 's/.*Signal level=\(.*\) dBm.*/\1/')
                    
                    # Calculate percentage
                    quality_num=$(echo $quality_raw | cut -d'/' -f1)
                    quality_max=$(echo $quality_raw | cut -d'/' -f2)
                    quality_percent=$((quality_num * 100 / quality_max))
                    
                    # Display both percentage and dBm if available
                    if [[ -n "$signal_level" ]]; then
                        if [[ $quality_percent -ge 70 ]]; then
                            current_quality="${GREEN}${quality_percent}% (${signal_level} dBm)${NC}"
                        elif [[ $quality_percent -ge 40 ]]; then
                            current_quality="${YELLOW}${quality_percent}% (${signal_level} dBm)${NC}"
                        else
                            current_quality="${RED}${quality_percent}% (${signal_level} dBm)${NC}"
                        fi
                    else
                        if [[ $quality_percent -ge 70 ]]; then
                            current_quality="${GREEN}${quality_percent}%${NC}"
                        elif [[ $quality_percent -ge 40 ]]; then
                            current_quality="${YELLOW}${quality_percent}%${NC}"
                        else
                            current_quality="${RED}${quality_percent}%${NC}"
                        fi
                    fi
                    
                elif [[ $line == *"Encryption key:on"* ]]; then
                    current_security="Encrypted"
                elif [[ $line == *"Encryption key:off"* ]]; then
                    current_security="Open"
                fi
            done <<< "$SCAN_RESULTS"
            
            # Print the last network
            if [[ -n "$current_essid" && -n "$current_channel" && -n "$current_quality" ]]; then
                # Remove escape sequences from display
                clean_essid=$(echo "$current_essid" | sed 's/\\x[0-9a-fA-F][0-9a-fA-F]//g' | tr -d '\r\n')
                printf "%-25s | %-7s | %-10s | %s\n" "$clean_essid" "$current_channel" "$current_quality" "$current_security"
            fi
            
            # Count networks found
            NETWORK_COUNT=$(echo "$SCAN_RESULTS" | grep -c "ESSID")
            echo -e "\nFound $NETWORK_COUNT networks in range."
        else
            print_error "No networks found during scan."
            print_info "Check if your WiFi adapter is functioning properly or if there are networks in range."
        fi
    else
        print_error "The 'iwlist' command is not available. Cannot scan for networks."
        print_info "Consider installing wireless-tools package."
    fi
    
    echo
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    return 0
}

# Check current connection status
check_connection_status() {
    print_header "Checking Current WiFi Connection"
    
    # Get connected SSID
    CONNECTED_SSID=""
    
    if command_exists iwgetid; then
        CONNECTED_SSID=$(iwgetid $WIFI_INTERFACE -r 2>/dev/null)
    elif command_exists iwconfig; then
        CONNECTED_SSID=$(iwconfig $WIFI_INTERFACE 2>/dev/null | grep 'ESSID:' | awk -F'"' '{print $2}')
    elif command_exists nmcli; then
        CONNECTED_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)
    fi
    
    if [[ -n "$CONNECTED_SSID" && "$CONNECTED_SSID" != "off/any" ]]; then
        print_success "Connected to: $CONNECTED_SSID"
        
        # Get IP address
        if command_exists ip; then
            IP_ADDRESS=$(ip addr show $WIFI_INTERFACE | grep -oP 'inet \K[\d.]+')
            if [[ -n "$IP_ADDRESS" ]]; then
                print_success "IP address: $IP_ADDRESS"
            else
                print_error "No IP address assigned"
                print_info "This suggests a DHCP issue or authentication problem"
            fi
        fi
        
        # Check default gateway
        if command_exists ip; then
            DEFAULT_GATEWAY=$(ip route | grep default | grep $WIFI_INTERFACE | awk '{print $3}')
            if [[ -n "$DEFAULT_GATEWAY" ]]; then
                print_success "Default gateway: $DEFAULT_GATEWAY"
            else
                print_error "No default gateway found"
                print_info "This may cause internet connectivity issues"
            fi
        fi
    else
        print_error "Not connected to any WiFi network"
    fi
}

wait_for_user_input() {
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    read -p "  Press Enter to continue... "
}

# Display signal strength
check_signal_strength() {
    print_header "Checking Signal Strength"
    
    if command_exists iwconfig; then
        SIGNAL_INFO=$(iwconfig $WIFI_INTERFACE 2>/dev/null | grep -E "Signal level|Quality")
        
        if [[ -n "$SIGNAL_INFO" ]]; then
            SIGNAL_LEVEL=$(echo "$SIGNAL_INFO" | grep -oP 'Signal level=\K[-0-9]+')
            QUALITY=$(echo "$SIGNAL_INFO" | grep -oP 'Quality=\K[0-9]+/[0-9]+')
            
            if [[ -n "$SIGNAL_LEVEL" ]]; then
                # Evaluate signal strength
                if [[ "$SIGNAL_LEVEL" -ge -50 ]]; then
                    print_success "Excellent signal strength: ${SIGNAL_LEVEL} dBm"
                elif [[ "$SIGNAL_LEVEL" -ge -70 ]]; then
                    print_warning "Good signal strength: ${SIGNAL_LEVEL} dBm"
                    print_info "You may experience occasional connectivity issues in some areas."
                else
                    print_error "Poor signal strength: ${SIGNAL_LEVEL} dBm"
                    print_info "Consider moving closer to the access point or using a WiFi extender."
                    print_info "Signal strength below -70 dBm often leads to dropped connections and slow speeds."
                fi
            elif [[ -n "$QUALITY" ]]; then
                # Parse quality as a percentage
                QUALITY_NUM=$(echo $QUALITY | cut -d'/' -f1)
                QUALITY_MAX=$(echo $QUALITY | cut -d'/' -f2)
                QUALITY_PCT=$((QUALITY_NUM * 100 / QUALITY_MAX))
                
                # Evaluate based on percentage
                if [[ "$QUALITY_PCT" -ge 80 ]]; then
                    print_success "Excellent signal quality: ${QUALITY_PCT}%"
                elif [[ "$QUALITY_PCT" -ge 50 ]]; then
                    print_warning "Good signal quality: ${QUALITY_PCT}%"
                    print_info "You may experience occasional connectivity issues in some areas."
                else
                    print_error "Poor signal quality: ${QUALITY_PCT}%"
                    print_info "Consider moving closer to the access point or using a WiFi extender."
                fi
            else
                print_error "Unable to determine signal strength"
            fi
        else
            print_error "Failed to retrieve signal information"
        fi
    elif command_exists nmcli; then
        # Try using nmcli to get signal strength
        SIGNAL_INFO=$(nmcli -f SIGNAL dev wifi list | grep -v SIGNAL | sort -nr | head -1)
        
        if [[ -n "$SIGNAL_INFO" ]]; then
            SIGNAL_STRENGTH=$(echo "$SIGNAL_INFO" | awk '{print $1}')
            
            if [[ -n "$SIGNAL_STRENGTH" ]]; then
                # Evaluate signal strength (percentage in nmcli)
                if [[ "$SIGNAL_STRENGTH" -ge 80 ]]; then
                    print_success "Excellent signal strength: ${SIGNAL_STRENGTH}%"
                elif [[ "$SIGNAL_STRENGTH" -ge 50 ]]; then
                    print_warning "Good signal strength: ${SIGNAL_STRENGTH}%"
                    print_info "You may experience occasional connectivity issues in some areas."
                else
                    print_error "Poor signal strength: ${SIGNAL_STRENGTH}%"
                    print_info "Consider moving closer to the access point or using a WiFi extender."
                fi
            else
                print_error "Unable to determine signal strength"
            fi
        else
            print_error "Failed to retrieve signal information"
        fi
    else
        print_error "Neither iwconfig nor nmcli commands found. Cannot check signal strength."
    fi
    echo
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    read -p "  Press Enter to continue... "
    return 0
# Test Internet connectivity
check_internet_connectivity() {
    print_header "Testing Internet Connectivity"
    
    # Define common test targets
    TARGETS=("google.com" "cloudflare.com" "1.1.1.1")
    
    if command_exists ping; then
        echo "Performing connectivity tests..."
        all_successful=true
        
        for target in "${TARGETS[@]}"; do
            echo -n "Testing connection to $target... "
            if ping -c 3 -W 2 "$target" > /dev/null 2>&1; then
                echo -e "${GREEN}Success${NC}"
            else
                echo -e "${RED}Failed${NC}"
                all_successful=false
            fi
        done
        
        if [ "$all_successful" = true ]; then
            print_success "Internet connectivity is working properly"
        else
            print_warning "Some connectivity tests failed"
            
            # Check if DNS is working
            if command_exists nslookup || command_exists host; then
                echo -e "\nTesting DNS resolution..."
                
                if command_exists nslookup; then
                    DNS_TEST=$(nslookup google.com 2>&1)
                else
                    DNS_TEST=$(host google.com 2>&1)
                fi
                
                if echo "$DNS_TEST" | grep -q "Address" && ! echo "$DNS_TEST" | grep -q "can't find"; then
                    print_success "DNS resolution is working"
                else
                    print_error "DNS resolution failed"
                    print_info "Check your DNS settings or try using alternative DNS servers like 8.8.8.8 or 1.1.1.1"
                fi
            fi
        fi
    else
        print_error "The 'ping' command is not available. Cannot test connectivity."
    fi
    
    echo
    echo
    echo -e "${BOLD}${BLUE}────────────────────────────────────────────────────────────────${NC}"
    echo
    read -p "  Press Enter to continue... "
    return 0
}
}

# Provide recommendations based on findings
provide_recommendations() {
    print_header "Recommendations"
    
    # If not connected to any network
    if [[ -z "$CONNECTED_SSID" || "$CONNECTED_SSID" == "off/any" ]]; then
        print_info "You are not connected to any WiFi network."
        print_info "Try the following:"
        echo "  1. Make sure WiFi is enabled and not blocked"
        echo "  2. Connect to an available network using your system's network manager"
        echo "  3. If your network is not visible, check router settings or try manual connection"
    fi
    
    # If connected but having IP issues
    if [[ -n "$CONNECTED_SSID" && -z "$IP_ADDRESS" ]]; then
        print_info "You're connected to a network but have no IP address."
        print_info "Try the following:"
        echo "  1. Renew your DHCP lease: sudo dhclient -r ${WIFI_INTERFACE} && sudo dhclient ${WIFI_INTERFACE}"
        echo "  2. Check if the router's DHCP server is functioning properly"
        echo "  3. Try setting a static IP address if DHCP continues to fail"
    fi
    
    # If signal strength is poor
    if [[ -n "$SIGNAL_LEVEL" && "$SIGNAL_LEVEL" -lt -70 ]]; then
        print_info "Your signal strength is poor. To improve it:"
        echo "  1. Move closer to your WiFi router or access point"
        echo "  2. Remove obstacles between your device and the router"
        echo "  3. Consider using a WiFi extender or mesh network system"
        echo "  4. Change your router's channel to avoid interference"
    fi
    
    # If there are connectivity issues
    if [ "$all_successful" = false ]; then
        print_info "You're having internet connectivity issues. Try these steps:"
        echo "  1. Restart your router/modem (unplug for 30 seconds, then plug back in)"
        echo "  2. Check if other devices can connect to the internet through the same network"
        echo "  3. Contact your ISP to check for outages in your area"
    fi
    
    # General advice
    print_info "General WiFi troubleshooting tips:"
    echo "  1. Restart your computer's network services: sudo systemctl restart NetworkManager"
    echo "  2. Update your WiFi adapter drivers"
    echo "  3. Ensure your router firmware is up to date"
    echo "  4. If problems persist, try resetting your router to factory defaults"
    echo "  5. For recurring issues, consider upgrading your router or WiFi adapter"
    
    echo
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    return 0
}



# Function to connect to WiFi networks
connect_to_wifi() {
    # Enable debug tracing
    set -x
    
    log_debug "Starting WiFi connection process"
    print_header "Connect to WiFi Network"
    
    # Check if WiFi interface is defined
    if [ -z "$WIFI_INTERFACE" ]; then
        log_debug "WiFi interface not defined, attempting to identify interfaces"
        if ! identify_wifi_interfaces; then
            log_error "Failed to identify WiFi interfaces"
            handle_error "Failed to identify WiFi interfaces."
            set +x
            return 1
        fi
        log_debug "WiFi interface identified: $WIFI_INTERFACE"
    else
        log_debug "Using WiFi interface: $WIFI_INTERFACE"
    fi
    
    # Ensure WiFi interface is up
    log_debug "Checking if interface $WIFI_INTERFACE is up"
    if ! ip link show $WIFI_INTERFACE 2>/dev/null | grep -q "state UP"; then
        log_debug "Interface $WIFI_INTERFACE is not UP"
        print_warning "WiFi interface $WIFI_INTERFACE is not UP."
        print_info "Attempting to bring it up..."
        if [ "$(id -u)" -eq 0 ]; then
            log_debug "Bringing up interface $WIFI_INTERFACE"
            if ! execute_cmd "ip link set $WIFI_INTERFACE up" "Failed to bring up interface $WIFI_INTERFACE"; then
                log_error "Command to bring up interface failed"
                print_error "Failed to bring interface up."
                set +x
                return 1
            fi
            sleep 2
            if ! ip link show $WIFI_INTERFACE 2>/dev/null | grep -q "state UP"; then
                log_error "Interface $WIFI_INTERFACE did not come up after command"
                print_error "Failed to bring interface up."
                set +x
                return 1
            fi
            log_debug "Successfully brought up interface $WIFI_INTERFACE"
        else
            log_error "Root privileges required to bring up interface"
            print_error "Root privileges required to bring up interface."
            set +x
            return 1
        fi
    else
        log_debug "Interface $WIFI_INTERFACE is already UP"
    fi
    
    # Scan for available networks
    log_debug "Scanning for available networks"
    print_info "Scanning for available networks..."
    
    # Determine which tool to use for scanning
    if command_exists nmcli; then
        log_debug "Using NetworkManager (nmcli) for scanning"
        # Using NetworkManager
        print_info "Refreshing network list..."
        execute_cmd "sudo nmcli device wifi rescan" "Failed to refresh WiFi networks" || true
        sleep 2
        NETWORKS=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>&1)
        local nmcli_status=$?
        
        if [[ $nmcli_status -ne 0 ]]; then
            log_error "nmcli scan failed with exit code $nmcli_status: $NETWORKS"
            print_error "Network scan failed: $NETWORKS"
            set +x
            return 1
        fi
        
        # Sort networks by signal strength
        NETWORKS=$(echo "$NETWORKS" | sort -t: -k2 -nr)
        
        if [[ -z "$NETWORKS" ]]; then
            log_error "No networks found during nmcli scan"
            print_error "No networks found or unable to scan."
            set +x
            return 1
        fi
        
        log_debug "Found networks via nmcli: $(echo "$NETWORKS" | wc -l) networks available"
        
        # Display available networks
        echo -e "\n${BLUE}Available Networks:${NC}"
        echo -e "${BLUE}#  SSID                     | Signal | Security${NC}"
        echo -e "---------------------------------------------------"
        
        # Create an array of SSIDs
        mapfile -t NETWORK_ARRAY <<< "$NETWORKS"
        
        # Display networks with numbers
        i=1
        for network in "${NETWORK_ARRAY[@]}"; do
            ssid=$(echo "$network" | cut -d':' -f1)
            signal=$(echo "$network" | cut -d':' -f2)
            security=$(echo "$network" | cut -d':' -f3-)
            
            # Skip empty SSIDs
            # Skip empty SSIDs
            if [[ -z "$ssid" ]]; then
                continue
            fi
            # Format security info - improved detection
            if [[ "$security" == *"WPA3"* ]]; then
                security="WPA3"
            elif [[ "$security" == *"WPA2"* ]]; then
                security="WPA2"
            elif [[ "$security" == *"WPA"* ]]; then
                security="WPA"
            elif [[ "$security" == *"WEP"* ]]; then
                security="WEP"
            elif [[ -z "$security" ]]; then
                security="Open"
            fi
            if [[ $signal -ge 70 ]]; then
                signal_display="${GREEN}${signal}%${NC}"
            elif [[ $signal -ge 40 ]]; then
                signal_display="${YELLOW}${signal}%${NC}"
            else
                signal_display="${RED}${signal}%${NC}"
            fi
            
            printf "%2d. %-25s | %-6s | %s\n" $i "${ssid:0:25}" "$signal_display" "$security"
            i=$((i+1))
        done
        
        # Prompt user to select a network
        echo
        echo -n "Enter the number of the network to connect to (or 0 to cancel): "
        read -r selection
        
        # Validate selection
        if [[ ! "$selection" =~ ^[0-9]+$ ]]; then
            print_error "Invalid selection. Please enter a number."
            return 1
        fi
        
        if [[ "$selection" -eq 0 ]]; then
            print_info "Connection cancelled."
            return 0
        fi
        
        if [[ "$selection" -lt 1 || "$selection" -gt ${#NETWORK_ARRAY[@]} ]]; then
            print_error "Invalid selection. Please enter a number between 1 and ${#NETWORK_ARRAY[@]}."
            return 1
        fi
        
        # Get selected network details
        selected_network="${NETWORK_ARRAY[$((selection-1))]}"
        selected_ssid=$(echo "$selected_network" | cut -d':' -f1)
        selected_security=$(echo "$selected_network" | cut -d':' -f3-)
        # Get selected network details (already retrieved above)
        
        # Determine security type and key management
        security_info=$(determine_wifi_security "$selected_security")
        key_mgmt=$(echo "$security_info" | cut -d':' -f1)
        auth_type=$(echo "$security_info" | cut -d':' -f2)
        
        log_debug "Network '$selected_ssid' has security: $selected_security, key_mgmt: $key_mgmt, auth_type: $auth_type"
        
        # Check if a password is needed
        if [[ "$auth_type" != "Open" ]]; then
            echo -n "Enter password for '$selected_ssid' ($auth_type network): "
            read -rs password
            echo
            
            # Format and execute the connection command based on security type
            print_info "Connecting to '$selected_ssid'..."
            connection_cmd=$(format_connection_command "$selected_ssid" "$password" "$auth_type")
            log_debug "Connection command: $connection_cmd"
            
            connection_output=$(eval "$connection_cmd" 2>&1)
            connection_status=$?
        fi
        
        # Check connection result
        if [[ $connection_status -eq 0 ]]; then
            print_success "Successfully connected to '$selected_ssid'!"
            log_debug "Connection successful"
            
            # Wait for IP address assignment (with timeout)
            print_info "Waiting for IP address assignment..."
            local ip_wait_count=0
            local max_wait=15
            echo -n "Checking IP address: "
            while [[ $ip_wait_count -lt $max_wait ]]; do
                IP_ADDRESS=$(ip addr show $WIFI_INTERFACE | grep -oP 'inet \K[\d.]+')
                if [[ -n "$IP_ADDRESS" ]]; then
                    print_success "IP address assigned: $IP_ADDRESS"
                    break
                fi
                sleep 1
                echo -n "."
                ip_wait_count=$((ip_wait_count + 1))
            done
            echo
            
            if [[ -z "$IP_ADDRESS" ]]; then
                print_warning "No IP address assigned yet. The connection might still be establishing."
            fi
            
            # Check internet connectivity
            print_info "Testing internet connectivity..."
            if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
                print_success "Internet connectivity confirmed!"
            else
                print_warning "Connected to network, but no internet access detected."
                print_info "This might be due to incorrect password, captive portal, or ISP issues."
            fi
        else
            print_error "Failed to connect to '$selected_ssid'."
            
            # Parse and provide more specific error information
            if [[ "$connection_output" == *"Secrets were required"* ]]; then
                print_error "Authentication failed. The password you provided may be incorrect."
            elif [[ "$connection_output" == *"timeout"* ]]; then
                print_error "Connection timed out. The network may be out of range or not responding."
            elif [[ "$connection_output" == *"802-11-wireless-security.key-mgmt"* ]]; then
                print_error "Security configuration error. The security type may not be supported."
                log_error "Security configuration error details: $connection_output"
                
                # Try alternate connection method with simpler command
                print_info "Attempting connection with alternate method..."
                alt_cmd="sudo nmcli device wifi connect \"$selected_ssid\" password \"$password\""
                log_debug "Alternate command: $alt_cmd"
                alt_output=$(eval "$alt_cmd" 2>&1)
                alt_status=$?
                
                if [[ $alt_status -eq 0 ]]; then
                    print_success "Successfully connected with alternate method!"
                else
                    print_error "Alternate connection method also failed."
                    print_error "Error details: $alt_output"
                fi
            else
                print_error "Error details: $connection_output"
            fi
            
            print_info "TIP: For persistent networks, try using: nmcli connection add type wifi con-name \"$selected_ssid\" ifname $WIFI_INTERFACE ssid \"$selected_ssid\""
        fi
    elif command_exists iwlist && command_exists wpa_supplicant; then
        log_debug "Using iwlist and wpa_supplicant for manual scanning"
        # Using wpa_supplicant (more manual approach)
        # Scan for networks
        local scan_output
        scan_output=$(sudo iwlist $WIFI_INTERFACE scan 2>&1)
        local scan_status=$?
        
        if [[ $scan_status -ne 0 ]]; then
            log_error "iwlist scan failed with exit code $scan_status: $scan_output"
            print_error "Network scan failed: $scan_output"
            set +x
            return 1
        fi
        
        SCAN_RESULTS=$(echo "$scan_output" | grep -E "ESSID|Quality|Encryption|Channel")
        
        if [[ -z "$SCAN_RESULTS" ]]; then
            log_error "No networks found in iwlist scan results"
            print_error "No networks found or unable to scan."
            set +x
            return 1
        fi
        
        log_debug "Networks found via iwlist scan"
        
        # Parse and display networks
        echo -e "\n${BLUE}Available Networks:${NC}"
        echo -e "${BLUE}#  SSID                     | Channel | Signal      | Security${NC}"
        echo -e "-----------------------------------------------------------"
        
        # Create arrays to store network information
        declare -a essids
        declare -a channels
        declare -a qualities
        declare -a securities
        
        current_essid=""
        current_channel=""
        current_quality=""
        current_security=""
        network_count=0
        
        while IFS= read -r line; do
            if [[ $line == *"ESSID"* ]]; then
                # If we have a complete network, save it
                if [[ -n "$current_essid" && -n "$current_channel" && -n "$current_quality" ]]; then
                    # Remove escape sequences and quotes
                    clean_essid=$(echo "$current_essid" | sed 's/\\x[0-9a-fA-F][0-9a-fA-F]//g' | tr -d '"\r\n')
                    
                    essids+=("$clean_essid")
                    channels+=("$current_channel")
                    qualities+=("$current_quality")
                    securities+=("$current_security")
                    
                    # Print with index
                    network_count=$((network_count + 1))
                    
                    # Format quality for display
                    quality_percent=$(echo "$current_quality" | grep -oP '[0-9]+(?=%)')
                    if [[ -n "$quality_percent" ]]; then
                        if [[ $quality_percent -ge 70 ]]; then
                            quality_display="${GREEN}${quality_percent}%${NC}"
                        elif [[ $quality_percent -ge 40 ]]; then
                            quality_display="${YELLOW}${quality_percent}%${NC}"
                        else
                            quality_display="${RED}${quality_percent}%${NC}"
                        fi
                    else
                        quality_display="$current_quality"
                    fi
                    
                    printf "%2d. %-25s | %-7s | %-10s | %s\n" $network_count "${clean_essid:0:25}" "$current_channel" "$quality_display" "$current_security"
                fi
                
                # Start a new network
                current_essid=$(echo "$line" | sed 's/.*ESSID:"\(.*\)".*/\1/')
                current_channel=""
                current_quality=""
                current_security=""
                
            elif [[ $line == *"Channel"* ]]; then
                current_channel=$(echo "$line" | sed 's/.*Channel:\(.*\).*/\1/' | tr -d ' ')
                
            elif [[ $line == *"Quality"* ]]; then
                quality_raw=$(echo "$line" | sed 's/.*Quality=\([0-9]*\/[0-9]*\).*/\1/')
                signal_level=$(echo "$line" | sed 's/.*Signal level=\(.*\) dBm.*/\1/')
                
                # Calculate percentage
                quality_num=$(echo $quality_raw | cut -d'/' -f1)
                quality_max=$(echo $quality_raw | cut -d'/' -f2)
                quality_percent=$((quality_num * 100 / quality_max))
                
                # Set current_quality
                if [[ -n "$signal_level" ]]; then
                    current_quality="${quality_percent}% (${signal_level} dBm)"
                else
                    current_quality="${quality_percent}%"
                fi
                
            elif [[ $line == *"Encryption key:on"* ]]; then
                current_security="Encrypted"
            elif [[ $line == *"Encryption key:off"* ]]; then
                current_security="Open"
            fi
        done <<< "$SCAN_RESULTS"
        
        # Add the last network if it exists
        if [[ -n "$current_essid" && -n "$current_channel" && -n "$current_quality" ]]; then
            clean_essid=$(echo "$current_essid" | sed 's/\\x[0-9a-fA-F][0-9a-fA-F]//g' | tr -d '"\r\n')
            
            essids+=("$clean_essid")
            channels+=("$current_channel")
            qualities+=("$current_quality")
            securities+=("$current_security")
            
            network_count=$((network_count + 1))
            
            # Format quality for display
            quality_percent=$(echo "$current_quality" | grep -oP '[0-9]+(?=%)')
            if [[ -n "$quality_percent" ]]; then
                if [[ $quality_percent -ge 70 ]]; then
                    quality_display="${GREEN}${quality_percent}%${NC}"
                elif [[ $quality_percent -ge 40 ]]; then
                    quality_display="${YELLOW}${quality_percent}%${NC}"
                else
                    quality_display="${RED}${quality_percent}%${NC}"
                fi
            else
                quality_display="$current_quality"
            fi
            
            printf "%2d. %-25s | %-7s | %-10s | %s\n" $network_count "${clean_essid:0:25}" "$current_channel" "$quality_display" "$current_security"
        fi
        
        if [[ $network_count -eq 0 ]]; then
            print_error "No networks found during parsing."
            return 1
        fi
        
        # Prompt user to select a network
        echo
        echo -n "Enter the number of the network to connect to (or 0 to cancel): "
        read -r selection
        
        # Validate selection
        if [[ ! "$selection" =~ ^[0-9]+$ ]]; then
            print_error "Invalid selection. Please enter a number."
            return 1
        fi
        
        if [[ "$selection" -eq 0 ]]; then
            print_info "Connection cancelled."
            return 0
        fi
        
        if [[ "$selection" -lt 1 || "$selection" -gt $network_count ]]; then
            print_error "Invalid selection. Please enter a number between 1 and $network_count."
            return 1
        fi
        
        # Get selected network details
        selected_index=$((selection - 1))
        selected_ssid="${essids[$selected_index]}"
        selected_security="${securities[$selected_index]}"
        
        # Temporary WPA supplicant configuration file
        wpa_config="/tmp/wpa_supplicant_$$.conf"
        
        # Create WPA supplicant configuration
        echo "ctrl_interface=/var/run/wpa_supplicant" > "$wpa_config"
        echo "ctrl_interface_group=0" >> "$wpa_config"
        echo "network={" >> "$wpa_config"
        echo "    ssid=\"$selected_ssid\"" >> "$wpa_config"
        
        # Determine security type and key management
        security_info=$(determine_wifi_security "$selected_security")
        key_mgmt=$(echo "$security_info" | cut -d':' -f1)
        auth_type=$(echo "$security_info" | cut -d':' -f2)
        
        log_debug "WPA config for '$selected_ssid' has security: $selected_security, key_mgmt: $key_mgmt, auth_type: $auth_type"
        
        # Check if a password is required
        if [[ "$auth_type" != "Open" ]]; then
            echo -n "Enter password for '$selected_ssid' ($auth_type network): "
            read -rs password
            echo
            
            # Add appropriate configuration based on security type
            case "$auth_type" in
                "WPA3"|"WPA2"|"WPA")
                    # Generate PSK hash for WPA networks
                    echo "    psk=\"$password\"" >> "$wpa_config"
                    echo "    key_mgmt=WPA-PSK" >> "$wpa_config"
                    if [[ "$auth_type" == "WPA3" ]]; then
                        echo "    ieee80211w=2" >> "$wpa_config"  # Required for WPA3
                    fi
                    ;;
                "WEP")
                    # For WEP networks
                    echo "    key_mgmt=NONE" >> "$wpa_config"
                    echo "    wep_key0=\"$password\"" >> "$wpa_config"
                    echo "    wep_tx_keyidx=0" >> "$wpa_config"
                    ;;
                *)
                    # Fallback
                    echo "    psk=\"$password\"" >> "$wpa_config"
                    ;;
            esac
        else
            # For open networks
            echo "    key_mgmt=NONE" >> "$wpa_config"
        fi
        
        
        # Close the network configuration block
        echo "}" >> "$wpa_config"
        log_debug "Created WPA supplicant configuration at $wpa_config"
        # Stop any existing connections
        print_info "Disconnecting from any existing networks..."
        log_debug "Stopping any existing wpa_supplicant and dhclient processes"
        sudo killall wpa_supplicant dhclient 2>/dev/null
        
        log_debug "Bringing interface $WIFI_INTERFACE down"
        if ! execute_cmd "sudo ip link set $WIFI_INTERFACE down" "Failed to bring interface down"; then
            log_error "Could not bring interface down before connection"
            print_error "Failed to reset interface. Continuing anyway..."
        fi
        
        log_debug "Bringing interface $WIFI_INTERFACE up again"
        if ! execute_cmd "sudo ip link set $WIFI_INTERFACE up" "Failed to bring interface up"; then
            log_error "Could not bring interface up after reset"
            print_error "Failed to reset interface. Connection may fail."
        fi
        sleep 1
        # Connect using wpa_supplicant
        print_info "Attempting to connect to '$selected_ssid'..."
        log_debug "Starting wpa_supplicant for connection to '$selected_ssid'"
        
        local wpa_output
        wpa_output=$(sudo wpa_supplicant -B -i $WIFI_INTERFACE -c "$wpa_config" 2>&1)
        local wpa_status=$?
        
        if [[ $wpa_status -ne 0 ]]; then
            log_error "wpa_supplicant failed with exit code $wpa_status: $wpa_output"
            print_error "Failed to start wpa_supplicant: $wpa_output"
            set +x
            return 1
        else
            log_debug "wpa_supplicant started successfully"
        fi
        
        sleep 2
        
        # Check if connection was successful
        local iwconfig_output
        iwconfig_output=$(iwconfig $WIFI_INTERFACE 2>&1)
        log_debug "iwconfig output: $iwconfig_output"
        
        if echo "$iwconfig_output" | grep -q "ESSID:\"$selected_ssid\""; then
            log_debug "Successfully connected to '$selected_ssid'"
            print_success "Connected to WiFi network: $selected_ssid"
            
            # Get IP address via DHCP
            log_debug "Running dhclient for interface $WIFI_INTERFACE"
            local dhclient_output
            local dhclient_status
            dhclient_output=$(sudo dhclient -v $WIFI_INTERFACE 2>&1)
            dhclient_status=$?
            
            # Check if we got an IP address
            IP_ADDRESS=$(ip addr show $WIFI_INTERFACE | grep -oP 'inet \K[\d.]+')
            if [[ -n "$IP_ADDRESS" ]]; then
                print_success "IP address assigned: $IP_ADDRESS"
                
                # Get and display gateway information
                DEFAULT_GATEWAY=$(ip route | grep default | grep $WIFI_INTERFACE | awk '{print $3}')
                if [[ -n "$DEFAULT_GATEWAY" ]]; then
                    print_success "Default gateway: $DEFAULT_GATEWAY"
                else
                    print_warning "No default gateway found. Routing might be incomplete."
                fi
                
                # Get and display DNS information
                if [ -f /etc/resolv.conf ]; then
                    DNS_SERVERS=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
                    if [[ -n "$DNS_SERVERS" ]]; then
                        print_success "DNS servers: $(echo $DNS_SERVERS | tr '\n' ' ')"
                    else
                        print_warning "No DNS servers found in /etc/resolv.conf"
                    fi
                fi
                
                # Test internet connectivity
                print_info "Testing internet connectivity..."
                
                # First try to ping the gateway
                if ping -c 1 -W 2 "$DEFAULT_GATEWAY" > /dev/null 2>&1; then
                    print_success "Gateway connectivity confirmed!"
                    
                    # Then try to ping a public DNS server
                    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
                        print_success "Internet connectivity confirmed!"
                        
                        # Finally, try to resolve and ping a domain name to test DNS
                        if ping -c 1 -W 2 google.com > /dev/null 2>&1; then
                            print_success "DNS resolution working properly!"
                        else
                            print_warning "Internet is accessible, but DNS resolution may have issues."
                            print_info "You might need to configure DNS servers manually."
                        fi
                    else
                        print_warning "Connected to gateway, but no internet access detected."
                        print_info "This might be an ISP issue or a router configuration problem."
                    fi
                else
                    print_warning "Connected to network, but cannot reach the gateway."
                    print_info "This might indicate a local network configuration issue."
                fi
            else
                print_error "Failed to obtain IP address."
                log_error "DHCP failed to assign an IP address to interface $WIFI_INTERFACE"
                
                # Try to debug DHCP issues
                if [[ $dhclient_status -ne 0 ]]; then
                    print_error "DHCP client error: $dhclient_output"
                fi
                
                print_info "You might try setting a static IP address manually."
            fi
        else
            print_error "Failed to connect to the selected network."
            log_error "WiFi connection to '$selected_ssid' failed. Could not verify using iwconfig"
            
            # Additional diagnostic information
            debug_info=$(iwconfig $WIFI_INTERFACE 2>&1)
            log_debug "Current iwconfig state: $debug_info"
            
            # Check for common failure causes
            if grep -q "No such device" <<< "$debug_info"; then
                print_error "The WiFi interface $WIFI_INTERFACE cannot be found. It may have been disconnected."
            elif grep -q "Resource busy" <<< "$wpa_output"; then
                print_error "Another process is using the WiFi interface. Try killing it with: sudo pkill wpa_supplicant"
            fi
            
            print_info "You may want to check the system logs for more information: sudo journalctl -u wpa_supplicant"
        fi
        
        # Clean up temporary configuration file
        rm -f "$wpa_config"
    else
        print_error "Cannot connect using manual method. Required tools not available."
        print_info "Please install wireless-tools and wpasupplicant packages."
    fi
    
    # Disable debug tracing
    set +x
    log_debug "WiFi connection process completed"
    
    echo
    echo -e "${BOLD}${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
    read -p "  Press Enter to continue... "
    return 0
}

# Main function
main() {
    # Initialize WiFi interface if possible without showing output
    if ! identify_wifi_interfaces > /dev/null 2>&1; then
        WIFI_INTERFACE=""
    fi

    while true; do
        display_menu
        read -r choice
        
        case $choice in
            1)
                scan_wifi_networks
                ;;
            2)
                check_connection_status
                wait_for_user_input
                ;;
            3)
                check_signal_strength
                ;;
            4)
                check_internet_connectivity
                ;;
            5)
                run_full_diagnostic
                ;;
            6)
                advanced_tools
                ;;
            7)
                clear
                echo -e "${GREEN}Thank you for using WiFi Troubleshooter!${NC}"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select a number between 1 and 7."
                wait_for_user_input
                ;;
        esac
    done
}

# Run the main function
main
