#!/bin/bash

# Configuration
THRESHOLD=80
CONFIG_FILE="/etc/myapp/config.conf"
LOG_FILE="/var/log/dynamic_config.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a ${LOG_FILE}
}

# Function to check server load
check_load() {
    local load=$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
    echo ${load%.*}
}

# Function to update configuration based on load
update_config() {
    local load=$1
    if [ $load -ge $THRESHOLD ]; then
        log_message "High load detected: $load. Updating configuration."
        sed -i 's/MaxConnections = 100/MaxConnections = 200/' ${CONFIG_FILE}
        systemctl restart myapp
        check_command "Updating configuration and restarting service"
    else
        log_message "Load is normal: $load."
    fi
}

# Main loop
while true; do
    current_load=$(check_load)
    update_config ${current_load}
    sleep 60
done
