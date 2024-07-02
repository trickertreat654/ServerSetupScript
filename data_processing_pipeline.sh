#!/bin/bash

# Configuration
DATA_DIR="/data"
PROCESSED_DIR="/processed"
LOG_FILE="/var/log/data_processing.log"

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

# Fetch data from sources
log_message "Fetching data from sources"
fetch_data() {
    local source=$1
    curl -o ${DATA_DIR}/${source}.json "https://api.example.com/${source}"
    check_command "Fetching data from ${source}"
}
export -f fetch_data
parallel fetch_data ::: source1 source2 source3

# Process data in parallel
log_message "Processing data"
process_data() {
    local file=$1
    jq '.data[] | select(.value > 100)' ${file} > ${PROCESSED_DIR}/$(basename ${file})
    check_command "Processing ${file}"
}
export -f process_data
find ${DATA_DIR} -name "*.json" | parallel process_data

log_message "Data processing completed successfully"
