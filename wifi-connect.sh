#!/bin/bash
#
# wifi-connect.sh - A user-friendly WiFi connection management script
#
# This script provides an interactive way to manage wireless connections
# using systemd-networkd and wpa_supplicant.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration paths
NETWORKD_PATH="/etc/systemd/network"
WPA_CONF_PATH="/etc/wpa_supplicant"
PROFILES_DIR="$HOME/.config/wifi-profiles"

# Ensure profiles directory exists
mkdir -p "$PROFILES_DIR"

# Function to display messages with color
print_message() {
    local type=$1
    local message=$2
    
    case $type in
        "error")
            echo -e "${RED}${BOLD}Error:${NC} $message"
            ;;
        "success")
            echo -e "${GREEN}${BOLD}Success:${NC} $message"
            ;;
        "info")
            echo -e "${BLUE}${BOLD}Info:${NC} $message"
            ;;
        "warning")
            echo -e "${YELLOW}${BOLD}Warning:${NC} $message"
            ;;
        "section")
            echo
            echo -e "${CYAN}${BOLD}=== $message ===${NC}"
            echo
            ;;
        *)
            echo -e "$message"
            ;;
    esac
}

# Function to get user confirmation
confirm() {
    local message=$1
    local default=${2:-"y"}
    
    local prompt
    if [ "$default" = "y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    read -p "$message $prompt " response
    response=${response:-$default}
    
    if [[ $response =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to detect wireless interface
get_wireless_interface() {
    # Try to find wireless interfaces
    local interfaces=($(ip link | grep -E 'wlan|wlp|wls' | cut -d: -f2 | tr -d ' '))
    
    if [ ${#interfaces[@]} -eq 0 ]; then
        print_message "error" "No wireless interface found"
        print_message "info" "Please ensure your wireless card is properly installed and recognized"
        return 1
    elif [ ${#interfaces[@]} -eq 1 ]; then
        # Only one interface found, use it automatically
        echo "${interfaces[0]}"
        return 0
    else
        # Multiple interfaces found, ask user to choose
        print_message "info" "Multiple wireless interfaces found:"
        
        for i in "${!interfaces[@]}"; do
            echo "[$i] ${interfaces[$i]}"
        done
        
        local choice
        read -p "Select interface [0-$((${#interfaces[@]}-1))]: " choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt "${#interfaces[@]}" ]; then
            echo "${interfaces[$choice]}"
            return 0
        else
            print_message "error" "Invalid selection"
            return 1
        fi
    fi
}

# Function to check for required tools and services
check_requirements() {
    print_message "info" "Checking system requirements..."
    
    # Check for required tools
    local missing_tools=()
    for cmd in ip wpa_supplicant wpa_cli systemctl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_tools+=("$cmd")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_message "error" "Required tools not found: ${missing_tools[*]}"
        print_message "info" "Please install the necessary packages (iproute2, wpa_supplicant, systemd)"
        
        if confirm "Would you like to install the required packages now?"; then
            sudo pacman -S --needed iproute2 wpa_supplicant systemd
            
            # Check again
            for cmd in "${missing_tools[@]}"; do
                if ! command -v "$cmd" &> /dev/null; then
                    print_message "error" "Failed to install $cmd. Please install it manually."
                    return 1
                fi
            done
            
            print_message "success" "Required packages installed successfully"
        else
            print_message "error" "Cannot continue without required tools."
            return 1
        fi
    fi
    
    # Check if systemd-networkd is running
    if ! systemctl is-active --quiet systemd-networkd; then
        print_message "warning" "systemd-networkd is not running"
        
        if confirm "Would you like to start and enable systemd-networkd?"; then
            sudo systemctl enable --now systemd-networkd
            if ! systemctl is-active --quiet systemd-networkd; then
                print_message "error" "Failed to start systemd-networkd"
                return 1
            else
                print_message "success" "systemd-networkd started successfully"
            fi
        else
            print_message "error" "Cannot continue without systemd-networkd."
            return 1
        fi
    fi
    
    # Check if systemd-resolved is running (for DNS resolution)
    if ! systemctl is-active --quiet systemd-resolved; then
        print_message "warning" "systemd-resolved is not running"
        
        if confirm "Would you like to start and enable systemd-resolved?"; then
            sudo systemctl enable --now systemd-resolved
            if ! systemctl is-active --quiet systemd-resolved; then
                print_message "warning" "Failed to start systemd-resolved. DNS resolution may not work properly."
            else
                print_message "success" "systemd-resolved started successfully"
                
                # Create symlink for resolv.conf if it doesn't exist
                if [ ! -L "/etc/resolv.conf" ] || [ "$(readlink /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ]; then
                    print_message "info" "Setting up DNS resolution with systemd-resolved..."
                    
                    if confirm "Configure system to use systemd-resolved for DNS?"; then
                        sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
                        print_message "success" "DNS configuration updated"
                    fi
                fi
            fi
        fi
    fi
    
    print_message "success" "System is ready for WiFi configuration"
    return 0
}

# Function to unblock wireless if blocked
unblock_wireless() {
    print_message "info" "Checking if wireless is blocked..."
    
    if command -v rfkill &> /dev/null; then
        if rfkill list wifi | grep -q "blocked: yes"; then
            print_message "warning" "Wireless is blocked. Attempting to unblock..."
            sudo rfkill unblock wifi
            print_message "success" "Wireless unblocked"
        else
            print_message "info" "Wireless is not blocked"
        fi
    else
        print_message "warning" "rfkill not found. Cannot check if wireless is blocked."
        
        if confirm "Would you like to install rfkill?"; then
            sudo pacman -S --needed rfkill
            
            if command -v rfkill &> /dev/null; then
                unblock_wireless
            else
                print_message "error" "Failed to install rfkill"
            fi
        fi
    fi
}

# Function to scan for networks
scan_networks() {
    local interface=$1
    print_message "section" "Scanning for Wireless Networks"
    print_message "info" "Using interface: $interface"
    
    # Check if wpa_supplicant service is running for this interface
    local wpa_running=false
    if systemctl is-active --quiet "wpa_supplicant@$interface" || [ -e "/run/wpa_supplicant/$interface" ]; then
        print_message "info" "Using existing wpa_supplicant service"
        wpa_running=true
    else
        print_message "info" "Starting temporary wpa_supplicant for scanning..."
        sudo wpa_supplicant -B -i "$interface" -C /run/wpa_supplicant
    fi
    
    # Scan for networks
    if sudo wpa_cli -i "$interface" scan > /dev/null 2>&1; then
        print_message "info" "Scanning... (this may take a few seconds)"
    else
        print_message "warning" "Failed to initiate scan. Trying alternative approach..."
        # Alternative scan using iw
        if command -v iw &> /dev/null; then
            sudo iw dev "$interface" scan > /dev/null 2>&1
        else
            print_message "error" "Could not scan for networks"
            return 1
        fi
    fi
    
    # Give it time to scan
    sleep 3
    
    # Display scan results in a user-friendly format
    print_message "section" "Available Networks"
    
    # Header
    echo "Index SSID                           Signal Strength  Security"
    echo "------------------------------------------------------------"
    
    # Attempt to get scan results, with a fallback to iw
    local scan_results=$(sudo wpa_cli -i "$interface" scan_results 2>/dev/null)
    
    if [ -z "$scan_results" ] && command -v iw &> /dev/null; then
        # Fallback to iw for scan results
        print_message "info" "Using iw for scan results"
        scan_results=$(sudo iw dev "$interface" scan | grep -E 'SSID:|signal:')
    fi
    
    # Process scan results
    local index=0
    echo "$scan_results" | grep -v "bssid" | while read -r line; do
        # Extract information
        local bssid=$(echo "$line" | awk '{print $1}')
        local signal=$(echo "$line" | awk '{print $3}')
        local flags=$(echo "$line" | awk '{print $4}')
        local ssid=$(echo "$line" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i}' | xargs)
        
        # Skip empty SSIDs (hidden networks)
        if [ -z "$ssid" ]; then
            ssid="<Hidden Network>"
        fi
        
        # Convert signal level to percentage (approximate)
        local signal_percent=$((100 + signal / 1))
        if [ "$signal_percent" -gt 100 ]; then signal_percent=100; fi
        if [ "$signal_percent" -lt 0 ]; then signal_percent=0; fi
        
        # Format signal strength as bars with separate color and text
        local bars=""
        local signal_text=""
        if [ "$signal_percent" -gt 80 ]; then
            bars="${GREEN}●●●●●${NC}"
            signal_text="Excellent (${signal_percent}%)"
        elif [ "$signal_percent" -gt 60 ]; then
            bars="${GREEN}●●●●${NC}○"
            signal_text="Very Good (${signal_percent}%)"
        elif [ "$signal_percent" -gt 40 ]; then
            bars="${YELLOW}●●●${NC}○○"
            signal_text="Good (${signal_percent}%)"
        elif [ "$signal_percent" -gt 20 ]; then
            bars="${YELLOW}●●${NC}○○○"
            signal_text="Fair (${signal_percent}%)"
        else
            bars="${RED}●${NC}○○○○"
            signal_text="Poor (${signal_percent}%)"
        fi
        
        # Determine security type
        local security="Open"
        local security_color=""
        if echo "$flags" | grep -q "WPA2-EAP"; then
            security="${YELLOW}Enterprise${NC}"
        elif echo "$flags" | grep -q "WPA2"; then
            security="${GREEN}WPA2${NC}"
        elif echo "$flags" | grep -q "WPA"; then
            security="${GREEN}WPA${NC}"
        elif echo "$flags" | grep -q "WEP"; then
            security="${RED}WEP${NC}"
        fi
        
        # Print network information
        echo -e "[${index}] ${ssid:0:32} ${bars} ${signal_text} ${security}"
        
        index=$((index+1))
    done
    
    # Clean up temporary wpa_supplicant if we started one
    if [ "$wpa_running" = false ]; then
        print_message "info" "Cleaning up temporary wpa_supplicant..."
        sudo wpa_cli -i "$interface" terminate > /dev/null 2>&1
    fi
    
    # Return success
    return 0
}

# Function to save network profile
save_network_profile() {
    local ssid="$1"
    local security_type="$2"
    local password="$3"
    local interface="$4"
    
    # Create profile name based on SSID
    local profile_name="${ssid// /_}_profile"
    local profile_file="$PROFILES_DIR/${profile_name}.conf"
    
    # Create profile configuration
    {
        echo "# WiFi Network Profile"
        echo "SSID='$ssid'"
        echo "INTERFACE='$interface'"
        echo "SECURITY_TYPE='$security_type'"
        
        # Add password if not an open network
        if [ "$security_type" != "open" ]; then
            echo "PASSWORD='$password'"
        fi
    } > "$profile_file"
    
    print_message "success" "Network profile saved: $profile_name"
}

# Function to connect to a network
connect_to_network() {
    local interface="$1"
    local target_ssid="$2"
    local password=""
    local hidden=false
    
    # If no SSID provided, scan and let user choose
    if [ -z "$target_ssid" ]; then
        scan_networks "$interface"
        
        read -p "Enter the network index or SSID to connect: " selection
        
        # Parse the selection (either index or SSID)
        if [[ "$selection" =~ ^[0-9]+$ ]]; then
            # If it's a number, treat as an index
            target_ssid=$(sudo wpa_cli -i "$interface" scan_results | grep -v "bssid" | sed -n "$((selection+1))p" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i}' | xargs)
            
            if [ -z "$target_ssid" ]; then
                print_message "error" "Invalid network selection"
                return 1
            fi
        else
            # If it's not a number, use it as the SSID
            target_ssid="$selection"
        fi
        
        # Ask if it's a hidden network
        if confirm "Is this a hidden network?" "n"; then
            hidden=true
        fi
    fi
    
    # Prompt for password if needed
    if [ -z "$password" ]; then
        read -sp "Enter password for $target_ssid (leave empty for open networks): " password
        echo
    fi

# Prepare wpa_supplicant configuration
    local wpa_conf_file="$WPA_CONF_PATH/wpa_supplicant-$interface.conf"
    
    # Ensure the wpa_supplicant configuration directory exists
    sudo mkdir -p "$WPA_CONF_PATH"
    
    # Determine network security type and create appropriate configuration
    if [ -z "$password" ]; then
        # Open network configuration
        print_message "info" "Configuring open network connection"
        sudo tee "$wpa_conf_file" > /dev/null << EOF
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
update_config=1

network={
    ssid="$target_ssid"
    key_mgmt=NONE
    scan_ssid=$( [ "$hidden" = true ] && echo "1" || echo "0" )
}
EOF
    else
        # Secured network configuration
        print_message "info" "Configuring secured network connection"
        
        # Generate PSK (Pre-Shared Key) for WPA networks
        local psk
        #if [[ "$password" =~ ^[0-9a-fA-F]{64}$ ]]; then
            # If password is already a 64-character hex PSK, use it directly
        #    psk="$password"
        #else
            # Generate PSK from passphrase
            psk=$(wpa_passphrase "$target_ssid" "$password" | grep 'psk=' | sed -n '2p' | cut -d= -f2)
        #fi
        
        # Create wpa_supplicant configuration file
        sudo tee "$wpa_conf_file" > /dev/null << EOF
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
update_config=1

network={
    ssid="$target_ssid"
    psk=$psk
    scan_ssid=$( [ "$hidden" = true ] && echo "1" || echo "0" )
}
EOF
    fi
    
    # Set strict permissions on the configuration file
    sudo chmod 600 "$wpa_conf_file"
    
    # Create network configuration for systemd-networkd
    create_network_config() {
        local interface="$1"
        local config_file="$NETWORKD_PATH/25-wireless.network"
        
        # Ensure the networkd configuration directory exists
        sudo mkdir -p "$NETWORKD_PATH"
        
        # Create a basic network configuration for DHCP
        sudo tee "$config_file" > /dev/null << EOF
[Match]
Name=$interface

[Network]
DHCP=yes

[DHCP]
RouteMetric=20
UseDNS=yes
UseNTP=yes
EOF
        
        print_message "success" "Network configuration created for $interface"
    }
    
    # Call the network configuration function
    create_network_config "$interface"
    
    # Stop any existing wpa_supplicant service for this interface
    sudo systemctl stop "wpa_supplicant@$interface.service" 2>/dev/null
    
    # Enable and start wpa_supplicant for this interface
    sudo systemctl enable --now "wpa_supplicant@$interface.service"
    
    # Restart networkd to apply changes
    sudo systemctl restart systemd-networkd
    
    # Wait for connection to establish
    print_message "info" "Attempting to connect to $target_ssid..."
    
    local attempts=0
    local max_attempts=20
    local connected=false
    
    while [ $attempts -lt $max_attempts ]; do
        attempts=$((attempts+1))
        
        # Check if an IP address has been assigned
        if ip addr show "$interface" | grep -q "inet "; then
            connected=true
            break
        fi
        
        echo -n "."
        sleep 1
    done
    
    echo  # New line after dots
    
    if [ "$connected" = true ]; then
        print_message "success" "Successfully connected to $target_ssid"
        
        # Optionally save the network profile
        if confirm "Would you like to save this network profile?" "y"; then
            # Determine security type for profile saving
            local security_type="open"
            if [ -n "$password" ]; then
                security_type="wpa"
            fi
            
            save_network_profile "$target_ssid" "$security_type" "$password" "$interface"
        fi
        
        return 0
    else
        print_message "error" "Failed to establish connection to $target_ssid"
        print_message "info" "Possible issues:"
        print_message "info" "- Incorrect password"
        print_message "info" "- Network out of range"
        print_message "info" "- Interference or signal issues"
        print_message "info" "Check logs with: journalctl -u wpa_supplicant@$interface.service"
        return 1
    fi
}

# Update show_usage function to include DNS option
show_usage() {
    print_message "section" "WiFi Connection Manager Usage"
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -s, --scan       Scan for available wireless networks"
    echo "  -c, --connect    Connect to a wireless network"
    echo "  -l, --list       List saved network profiles"
    echo "  -d, --dns        Configure DNS servers"
    echo
    echo "Examples:"
    echo "  $0 --scan        Scan for available networks"
    echo "  $0 --connect     Interactive network connection"
    echo "  $0 --dns         Manage DNS configuration"
}
#
#
# Main script execution
main() {
    # Check if running as root (which is not recommended)
    if [ "$(id -u)" -eq 0 ]; then
        print_message "error" "This script should not be run as root"
        print_message "info" "Use with your normal user account and sudo if needed"
        exit 1
    fi
    
    # Process command-line arguments
    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -s|--scan)
            # Check requirements and get interface
            check_requirements
            interface=$(get_wireless_interface)
            unblock_wireless
            scan_networks "$interface"
            exit 0
            ;;
        -c|--connect)
            # Check requirements and connect
            check_requirements
            interface=$(get_wireless_interface)
            unblock_wireless
            connect_to_network "$interface"
            exit 0
            ;;
        -l|--list)
            # List saved network profiles
            print_message "section" "Saved Network Profiles"
            if [ -d "$PROFILES_DIR" ] && [ "$(ls -A "$PROFILES_DIR"/*.conf 2>/dev/null)" ]; then
                for profile in "$PROFILES_DIR"/*.conf; do
                    # Extract SSID from profile
                    ssid=$(grep "SSID=" "$profile" | cut -d\' -f2)
                    echo "Profile: ${profile##*/} (SSID: $ssid)"
                done
            else
                print_message "info" "No saved network profiles found"
            fi
            exit 0
            ;;
        -d|--dns)
          configure_dns
          exit 0
          ;;
        "")
            # Interactive mode if no arguments
            check_requirements
            interface=$(get_wireless_interface)
            
            while true; do
                clear
                print_message "section" "WiFi Connection Manager"
                echo "1. Scan for Networks"
                echo "2. Connect to a Network"
                echo "3. List Saved Profiles"
                echo "4. DNS configuration"
                echo "5. Exit"
                
                read -p "Select an option [1-5]: " choice
                
                case "$choice" in
                    1)
                        unblock_wireless
                        scan_networks "$interface"
                        read -p "Press Enter to continue..."
                        ;;
                    2)
                        unblock_wireless
                        connect_to_network "$interface"
                        read -p "Press Enter to continue..."
                        ;;
                    3)
                        # List saved profiles
                        print_message "section" "Saved Network Profiles"
                        if [ -d "$PROFILES_DIR" ] && [ "$(ls -A "$PROFILES_DIR"/*.conf 2>/dev/null)" ]; then
                            for profile in "$PROFILES_DIR"/*.conf; do
                                ssid=$(grep "SSID=" "$profile" | cut -d\' -f2)
                                echo "Profile: ${profile##*/} (SSID: $ssid)"
                            done
                        else
                            print_message "info" "No saved network profiles found"
                        fi
                        read -p "Press Enter to continue..."
                        ;;
                    4)
                        configure_dns
                        ;;
                    5)
                        print_message "info" "Exiting. Goodbye!"
                        exit 0
                        ;;
                    *)
                        print_message "error" "Invalid option"
                        read -p "Press Enter to continue..."
                        ;;
                esac
            done
            ;;
        *)
            print_message "error" "Invalid option: $1"
            show_usage
            exit 1
            ;;
    esac
}

configure_dns() {
    print_message "section" "DNS Configuration Manager"
    
    # Check if systemd-resolved is running
    if ! systemctl is-active --quiet systemd-resolved; then
        print_message "warning" "systemd-resolved is not running"
        
        if confirm "Would you like to start systemd-resolved?"; then
            sudo systemctl enable --now systemd-resolved
            if ! systemctl is-active --quiet systemd-resolved; then
                print_message "error" "Failed to start systemd-resolved"
                return 1
            fi
        else
            print_message "error" "Cannot configure DNS without systemd-resolved"
            return 1
        fi
    fi
    
    # Menu for DNS configuration
    while true; do
        clear
        print_message "section" "DNS Configuration Options"
        echo "1. View Current DNS Servers"
        echo "2. Add Custom DNS Server"
        echo "3. Remove Custom DNS Server"
        echo "4. Reset to Default DNS Servers"
        echo "5. Return to Main Menu"
        
        read -p "Select an option [1-5]: " dns_choice
        
        case "$dns_choice" in
            1)  # View current DNS servers
                print_message "info" "Current DNS Servers:"
                resolvectl status | grep "DNS Servers" | while read -r line; do
                    echo "  $line"
                done
                read -p "Press Enter to continue..."
                ;;
            
            2)  # Add custom DNS server
                read -p "Enter DNS server IP address: " new_dns
                
                # Validate IP address format
                if [[ ! "$new_dns" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    print_message "error" "Invalid IP address format"
                    read -p "Press Enter to continue..."
                    continue
                fi
                
                # Create a network configuration to add DNS
                local interface=$(get_wireless_interface)
                local dns_conf_file="/etc/systemd/network/20-dns-${interface}.network"
                
                sudo tee "$dns_conf_file" > /dev/null << EOF
[Match]
Name=$interface

[Network]
DNS=$new_dns
EOF
                
                # Restart systemd-networkd to apply changes
                sudo systemctl restart systemd-networkd
                sudo systemctl restart systemd-resolved
                
                print_message "success" "Added $new_dns as DNS server for $interface"
                read -p "Press Enter to continue..."
                ;;
            
            3)  # Remove custom DNS server
                read -p "Enter DNS server IP address to remove: " remove_dns
                
                # Find and remove the DNS configuration file
                local dns_conf_files=($(find /etc/systemd/network -name "20-dns-*.network"))
                local removed=false
                
                for conf_file in "${dns_conf_files[@]}"; do
                    if grep -q "DNS=$remove_dns" "$conf_file"; then
                        sudo rm "$conf_file"
                        removed=true
                        break
                    fi
                done
                
                if [ "$removed" = true ]; then
                    # Restart services to apply changes
                    sudo systemctl restart systemd-networkd
                    sudo systemctl restart systemd-resolved
                    print_message "success" "Removed $remove_dns from DNS servers"
                else
                    print_message "error" "DNS server $remove_dns not found in configurations"
                fi
                read -p "Press Enter to continue..."
                ;;
            
            4)  # Reset to default DNS servers
                # Remove all custom DNS configuration files
                sudo rm /etc/systemd/network/20-dns-*.network 2>/dev/null
                
                # Restart services to revert to default
                sudo systemctl restart systemd-networkd
                sudo systemctl restart systemd-resolved
                
                print_message "success" "Reset to default DNS servers"
                read -p "Press Enter to continue..."
                ;;
            
            5)  # Exit DNS configuration
                break
                ;;
            
            *)
                print_message "error" "Invalid option"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}


# Run the main function with all provided arguments
main "$@"
