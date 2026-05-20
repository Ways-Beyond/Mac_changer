#!/bin/bash

# Aesthetic MAC Address Manager with logging, backups, colors, ASCII borders, and real-time status panel

LOG_FILE="/var/log/mac_manager.log"
BACKUP_DIR="/var/log/mac_manager_backups"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"
BOLD="\033[1m"

generate_random_mac() {
    hexchars="0123456789ABCDEF"
    echo 02$( for i in {1..5}; do echo -n ${hexchars:$(( $RANDOM % 16 )):1}${hexchars:$(( $RANDOM % 16 )):1}; done | sed -e 's/\(..\)/:\1/g' )
}

log_action() {
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $1" | sudo tee -a $LOG_FILE > /dev/null
}

list_interfaces() {
    echo -e "${CYAN}Available network interfaces:${RESET}"
    ip -o link show | awk -F': ' '{print $2}'
    log_action "Listed all interfaces"
}

status_panel() {
    echo -e "${BLUE}==== Real-Time Interface Status Panel ====${RESET}"
    printf "${BOLD}%-15s %-20s %-10s${RESET}\n" "Interface" "MAC Address" "Status"
    echo "----------------------------------------------------------"
    ip -o link show | while read -r line; do
        iface=$(echo $line | awk -F': ' '{print $2}')
        mac=$(ip link show $iface | grep ether | awk '{print $2}')
        state=$(echo $line | awk '{print $9}')
        if [[ "$state" == "UP" ]]; then
            indicator="✅ Active"
        else
            indicator="❌ Down"
        fi
        printf "%-15s %-20s %-10s\n" "$iface" "$mac" "$indicator"
    done
    log_action "Displayed real-time status panel with indicators"
}


change_mac() {
    echo -e "${YELLOW}Enter interface name (e.g., eth0, wlan0):${RESET}"
    read INTERFACE
    echo -e "${YELLOW}Enter new MAC (or press Enter for random):${RESET}"
    read NEW_MAC

    CURRENT_MAC=$(ip link show $INTERFACE | grep ether | awk '{print $2}')
    echo $CURRENT_MAC > /tmp/${INTERFACE}_original_mac.txt
    log_action "Saved original MAC for $INTERFACE: $CURRENT_MAC"

    if [ -z "$NEW_MAC" ]; then
        NEW_MAC=$(generate_random_mac)
    fi

    sudo ip link set dev $INTERFACE down
    sudo ip link set dev $INTERFACE address $NEW_MAC
    sudo ip link set dev $INTERFACE up

    UPDATED_MAC=$(ip link show $INTERFACE | grep ether | awk '{print $2}')
    log_action "Changed MAC of $INTERFACE from $CURRENT_MAC to $UPDATED_MAC"
    echo -e "${GREEN}MAC updated: $UPDATED_MAC${RESET}"
}

restore_mac() {
    echo -e "${YELLOW}Enter interface name to restore:${RESET}"
    read INTERFACE
    if [ -f /tmp/${INTERFACE}_original_mac.txt ]; then
        ORIGINAL_MAC=$(cat /tmp/${INTERFACE}_original_mac.txt)
        sudo ip link set dev $INTERFACE down
        sudo ip link set dev $INTERFACE address $ORIGINAL_MAC
        sudo ip link set dev $INTERFACE up
        log_action "Restored MAC of $INTERFACE to $ORIGINAL_MAC"
        echo -e "${GREEN}MAC restored: $ORIGINAL_MAC${RESET}"
    else
        echo -e "${RED}No backup MAC found for $INTERFACE.${RESET}"
    fi
}

view_mac() {
    echo -e "${YELLOW}Enter interface name to view:${RESET}"
    read INTERFACE
    CURRENT_MAC=$(ip link show $INTERFACE | grep ether | awk '{print $2}')
    echo -e "${CYAN}Current MAC: $CURRENT_MAC${RESET}"
    log_action "Viewed MAC of $INTERFACE: $CURRENT_MAC"
}

view_log() {
    echo -e "${BLUE}==== MAC Manager Log History ====${RESET}"
    if [ -f $LOG_FILE ]; then
        sudo cat $LOG_FILE
    else
        echo -e "${RED}No log file found yet.${RESET}"
    fi
}

search_log() {
    if [ -f $LOG_FILE ]; then
        echo -e "${YELLOW}Enter search keyword (e.g., eth0, Changed, Restored):${RESET}"
        read keyword
        echo -e "${CYAN}Search results for '${keyword}':${RESET}"
        sudo grep -i "$keyword" $LOG_FILE || echo -e "${RED}No matches found.${RESET}"
        log_action "Searched log for keyword: $keyword"
    else
        echo -e "${RED}No log file found to search.${RESET}"
    fi
}

clear_log() {
    if [ -f $LOG_FILE ]; then
        sudo truncate -s 0 $LOG_FILE
        echo -e "${RED}Log file cleared.${RESET}"
        log_action "Cleared log history"
    else
        echo -e "${RED}No log file found to clear.${RESET}"
    fi
}

backup_log() {
    if [ -f $LOG_FILE ]; then
        sudo mkdir -p $BACKUP_DIR
        BACKUP_FILE="$BACKUP_DIR/mac_manager_$(date +'%Y%m%d_%H%M%S').log"
        sudo cp $LOG_FILE $BACKUP_FILE
        echo -e "${GREEN}Log file backed up to $BACKUP_FILE${RESET}"
        log_action "Backed up log history to $BACKUP_FILE"
    else
        echo -e "${RED}No log file found to backup.${RESET}"
    fi
}

while true; do
    echo -e "${BOLD}${BLUE}┌───────────────────────────────────────┐${RESET}"
    echo -e "${BOLD}${CYAN}│         MAC Address Manager           │${RESET}"
    echo -e "${BOLD}${BLUE}└───────────────────────────────────────┘${RESET}"
    echo -e "${YELLOW}1) List Interfaces${RESET}"
    echo -e "${YELLOW}2) Real-Time Status Panel${RESET}"
    echo -e "${YELLOW}3) Change MAC${RESET}"
    echo -e "${YELLOW}4) Restore MAC${RESET}"
    echo -e "${YELLOW}5) View Current MAC${RESET}"
    echo -e "${YELLOW}6) View Log History${RESET}"
    echo -e "${YELLOW}7) Search Log History${RESET}"
    echo -e "${YELLOW}8) Clear Log History${RESET}"
    echo -e "${YELLOW}9) Backup Log History${RESET}"
    echo -e "${YELLOW}10) Exit${RESET}"
    echo -e "${CYAN}Choose an option:${RESET}"
    read choice

    case $choice in
        1) list_interfaces ;;
        2) status_panel ;;
        3) change_mac ;;
        4) restore_mac ;;
        5) view_mac ;;
        6) view_log ;;
        7) search_log ;;
        8) clear_log ;;
        9) backup_log ;;
        10) echo -e "${GREEN}Goodbye!${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option, try again.${RESET}" ;;
    esac
done
