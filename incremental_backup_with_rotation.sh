#!/bin/bash

# Configuration
BACKUP_DIR="/backups"
SOURCE_DIR="/data"
LOG_FILE="/var/log/backup.log"
MAX_BACKUPS=7

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a ${LOG_FILE}
}

# Function to check the success of a command and exit if it fails
check_command() {
    if [ $? -ne 0 ]; then
        log_message "Error: $1 failed."
        exit 1
    fi
}

# Create backup
log_message "Creating backup"
tar -czf ${BACKUP_DIR}/backup-$(date +%F).tar.gz -g ${BACKUP_DIR}/backup.snar ${SOURCE_DIR}
check_command "Creating backup"

# Rotate old backups
log_message "Rotating old backups"
ls -1tr ${BACKUP_DIR}/backup-*.tar.gz | head -n -${MAX_BACKUPS} | xargs rm -f
check_command "Rotating backups"

log_message "Backup and rotation completed successfully"
