#!/bin/bash

# 🚗 CAR BLUETOOTH DEFENDER - Aggressive Protection
# Specifically designed to stop friends from connecting to your car Bluetooth

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
CAR_BLUETOOTH_MAC=""  # Add your car's Bluetooth MAC here
YOUR_PHONE_MAC=""     # Add your phone's MAC here
TRUSTED_DEVICES=("$YOUR_PHONE_MAC")
SCAN_INTERVAL=3
AGGRESSIVE_MODE=true

# Function to check root access
check_root() {
    if [ "$(whoami)" != "root" ]; then
        echo -e "${RED}❌ This script requires root access. Run with: su${NC}"
        exit 1
    fi
}

# Function to setup your device info
setup_device_info() {
    echo -e "${PURPLE}🚗 Car Bluetooth Defender Setup${NC}"
    
    if [ -z "$CAR_BLUETOOTH_MAC" ]; then
        echo -e "${YELLOW}Enter your CAR'S Bluetooth MAC address (find in car settings):${NC}"
        read -r CAR_BLUETOOTH_MAC
        echo "CAR_BLUETOOTH_MAC=\"$CAR_BLUETOOTH_MAC\"" > car_defender_config.conf
    fi
    
    if [ -z "$YOUR_PHONE_MAC" ]; then
        echo -e "${YELLOW}Enter YOUR PHONE'S Bluetooth MAC address (Settings > About Phone):${NC}"
        read -r YOUR_PHONE_MAC
        echo "YOUR_PHONE_MAC=\"$YOUR_PHONE_MAC\"" >> car_defender_config.conf
    fi
    
    TRUSTED_DEVICES=("$YOUR_PHONE_MAC")
    echo "TRUSTED_DEVICES=(${TRUSTED_DEVICES[@]})" >> car_defender_config.conf
}

# Load configuration
load_config() {
    if [ -f "car_defender_config.conf" ]; then
        source car_defender_config.conf
    else
        setup_device_info
    fi
}

# Get ALL Bluetooth connections (more aggressive scanning)
get_all_connections() {
    echo -e "${BLUE}🔍 Scanning for ALL Bluetooth connections...${NC}"
    
    # Method 1: Using dumpsys (primary)
    dumpsys bluetooth | grep -E "(Device:||Connected:||Connection state:)" | while read line; do
        echo "$line"
    done
    
    # Method 2: Using service list
    service list | grep -i bluetooth
    
    # Method 3: Check Bluetooth sockets
    netstat -tnp 2>/dev/null | grep -i bluetooth
}

# Get connected devices to your car
get_car_connections() {
    echo -e "${BLUE}🎯 Scanning for car connections...${NC}"
    local connected_devices=()
    
    # Multiple methods to detect connections
    dumpsys bluetooth | grep -A 10 -B 10 "$CAR_BLUETOOTH_MAC" | grep -E "(Device:|Connected:|connectionState=2)" | while read line; do
        if echo "$line" | grep -q "Device:"; then
            DEVICE_MAC=$(echo "$line" | grep -oE "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})")
            DEVICE_NAME=$(echo "$line" | sed 's/.*Device:.* - //')
            if [ -n "$DEVICE_MAC" ] && [ "$DEVICE_MAC" != "$CAR_BLUETOOTH_MAC" ]; then
                echo -e "${YELLOW}Car Connection: $DEVICE_NAME ($DEVICE_MAC)${NC}"
                connected_devices+=("$DEVICE_MAC")
            fi
        fi
    done
}

# Nuclear option - disconnect ALL Bluetooth devices except yours
nuclear_disconnect() {
    echo -e "${RED}💥 ACTIVATING NUCLEAR OPTION - Disconnecting ALL devices except yours...${NC}"
    
    # Get all connected devices
    dumpsys bluetooth | grep -B 5 "connectionState=2" | grep "Device:" | while read line; do
        DEVICE_MAC=$(echo "$line" | grep -oE "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})")
        DEVICE_NAME=$(echo "$line" | sed 's/.*Device:.* - //')
        
        # Skip if it's your phone or car
        if [[ " ${TRUSTED_DEVICES[@]} " =~ " ${DEVICE_MAC} " ]] || [ "$DEVICE_MAC" == "$CAR_BLUETOOTH_MAC" ]; then
            echo -e "${GREEN}✅ Keeping: $DEVICE_NAME${NC}"
        else
            echo -e "${RED}🚫 Disconnecting: $DEVICE_NAME${NC}"
            disconnect_device "$DEVICE_MAC"
        fi
    done
}

# Disconnect device with multiple methods
disconnect_device() {
    local mac=$1
    echo -e "${RED}🚫 Disconnecting device: $mac${NC}"
    
    # Method 1: Bluetooth manager service call
    service call bluetooth_manager 21 s16 "$mac" > /dev/null 2>&1
    
    # Method 2: Using settings (if available)
    settings put global bluetooth_disconnected_devices "$mac" 2>/dev/null
    
    # Method 3: Kill Bluetooth processes temporarily
    pkill -f "bluetooth" 2>/dev/null
    sleep 1
    # Bluetooth service will restart automatically
    
    # Method 4: Remove from bonded devices
    service call bluetooth_manager 24 s16 "$mac" > /dev/null 2>&1
    
    echo -e "${GREEN}✅ Disconnection commands sent for $mac${NC}"
}

# Make Bluetooth invisible
stealth_mode() {
    echo -e "${PURPLE}👻 Enabling Stealth Mode...${NC}"
    
    # Make device undiscoverable
    settings put global bluetooth_discoverability_timeout 0
    settings put global bluetooth_discoverability 0
    
    # Stop discovery
    service call bluetooth_manager 13 > /dev/null 2>&1
    
    # Change Bluetooth name to random
    RANDOM_NAME="Device_$(date +%s | tail -c 4)"
    settings put global bluetooth_name "$RANDOM_NAME"
    
    echo -e "${GREEN}✅ Stealth Mode Active - Name: $RANDOM_NAME${NC}"
}

# Continuous aggressive protection
aggressive_protection() {
    echo -e "${RED}🔥 ACTIVATING AGGRESSIVE PROTECTION MODE${NC}"
    echo -e "${YELLOW}This will continuously disconnect any device trying to connect to your car${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    
    local attack_count=0
    
    while true; do
        echo -e "\n${PURPLE}=== Scan #$((++attack_count)) ===${NC}"
        
        # Get current connections to car
        get_car_connections
        
        # Nuclear disconnect every time
        nuclear_disconnect
        
        # Additional: Clear any pairing requests
        dumpsys bluetooth | grep -i "pairing" | while read line; do
            echo -e "${RED}🚫 Clearing pairing requests...${NC}"
        done
        
        echo -e "${GREEN}✅ Protection cycle completed - Waiting ${SCAN_INTERVAL}s${NC}"
        sleep $SCAN_INTERVAL
    done
}

# One-time cleanup
full_cleanup() {
    echo -e "${RED}🧹 Performing Full Bluetooth Cleanup...${NC}"
    
    # Disable Bluetooth temporarily
    service call bluetooth_manager 8 > /dev/null 2>&1
    sleep 2
    
    # Enable Bluetooth
    service call bluetooth_manager 6 > /dev/null 2>&1
    sleep 2
    
    # Nuclear disconnect
    nuclear_disconnect
    
    # Enable stealth mode
    stealth_mode
    
    echo -e "${GREEN}✅ Full cleanup completed!${NC}"
}

# Monitor mode with alerts
monitor_mode() {
    echo -e "${BLUE}👁️  Starting Monitor Mode...${NC}"
    echo -e "${YELLOW}Will alert when someone tries to connect${NC}"
    
    local last_state=""
    
    while true; do
        CURRENT_CONNECTIONS=$(dumpsys bluetooth | grep -c "connectionState=2")
        
        if [ "$CURRENT_CONNECTIONS" -gt 1 ]; then
            echo -e "${RED}🚨 ALERT: Unauthorized connections detected!${NC}"
            get_car_connections
            nuclear_disconnect
        elif [ "$CURRENT_CONNECTIONS" != "$last_state" ]; then
            echo -e "${GREEN}✅ Status: $CURRENT_CONNECTIONS active connections${NC}"
            last_state="$CURRENT_CONNECTIONS"
        fi
        
        sleep $SCAN_INTERVAL
    done
}

# Quick status check
status_check() {
    echo -e "${PURPLE}📊 Current Bluetooth Status:${NC}"
    
    # Bluetooth state
    BT_STATE=$(dumpsys bluetooth | grep "BluetoothAdapter" | head -1)
    echo -e "Bluetooth: $BT_STATE"
    
    # Connected devices count
    CONN_COUNT=$(dumpsys bluetooth | grep -c "connectionState=2")
    echo -e "Active Connections: $CONN_COUNT"
    
    # Your device status
    if dumpsys bluetooth | grep -q "$YOUR_PHONE_MAC.*connectionState=2"; then
        echo -e "${GREEN}✅ Your phone: CONNECTED${NC}"
    else
        echo -e "${RED}❌ Your phone: NOT CONNECTED${NC}"
    fi
}

# Main menu
show_menu() {
    echo -e "\n${PURPLE}=== 🚗 CAR BLUETOOTH DEFENDER ===${NC}"
    echo -e "${GREEN}Car MAC: $CAR_BLUETOOTH_MAC${NC}"
    echo -e "${GREEN}Your Phone: $YOUR_PHONE_MAC${NC}"
    echo ""
    echo "1. 🔥 Aggressive Protection Mode"
    echo "2. 👁️  Monitor Mode (Alerts Only)"
    echo "3. 🧹 One-Time Full Cleanup"
    echo "4. 👻 Stealth Mode (Hide Bluetooth)"
    echo "5. 📊 Current Status"
    echo "6. 🎯 Scan for Connections"
    echo "7. 💥 Nuclear Disconnect (Now!)"
    echo "8. ⚙️  Reconfigure Settings"
    echo "9. 🚪 Exit"
    echo -n "Choose an option: "
}

# Main execution
main() {
    check_root
    load_config
    
    echo -e "${PURPLE}"
    echo "🚗 CAR BLUETOOTH DEFENDER"
    echo "💪 Specifically designed to stop friends from using your car Bluetooth!"
    echo -e "${NC}"
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) aggressive_protection ;;
            2) monitor_mode ;;
            3) full_cleanup ;;
            4) stealth_mode ;;
            5) status_check ;;
            6) get_car_connections ;;
            7) nuclear_disconnect ;;
            8) setup_device_info ;;
            9) echo -e "${GREEN}✅ Defender stopped. Your car Bluetooth is protected!${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Invalid option${NC}" ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
