#!/bin/bash

# Configuration
REPO_URL="my_repo_url"
BRANCH="main"
APP_DIR="/var/www/html/my_app"
DEPLOY_DIR="/var/www/html/my_app_deploy"
LOG_FILE="/var/log/deploy.log"
BACKUP_DIR="/var/www/html/backup"
ROLLBACK_DIR="/var/www/html/rollback"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a ${LOG_FILE}
}

# Function to check the success of a command and exit if it fails
check_command() {
    if [ $? -ne 0 ]; then
        log_message "Error: $1 failed. Initiating rollback."
        rollback
        exit 1
    fi
}

# Backup current deployment
log_message "Backing up current deployment"
mkdir -p ${BACKUP_DIR}
cp -r ${DEPLOY_DIR} ${BACKUP_DIR}/$(date +"%F-%T")
check_command "Backup"

# Pull the latest code from the repository
log_message "Pulling latest code"
cd ${APP_DIR}
git pull ${REPO_URL} ${BRANCH}
check_command "Pulling latest code"

# Install dependencies and run tests
log_message "Installing dependencies"
composer install --no-dev --optimize-autoloader
check_command "Installing PHP dependencies"
npm install
check_command "Installing Node.js dependencies"

log_message "Running tests"
php artisan test > ${APP_DIR}/test_results.txt
TEST_EXIT_CODE=$?
if [ ${TEST_EXIT_CODE} -ne 0 ]; then
    log_message "Tests failed. Initiating rollback."
    rollback
    exit 1
else
    log_message "Tests passed"
fi

# Deploy the application
log_message "Deploying application"
rsync -av --delete ${APP_DIR}/ ${DEPLOY_DIR}/
check_command "Deploying application"

# Clear caches and restart services
log_message "Clearing caches and restarting services"
php artisan config:cache
php artisan route:cache
php artisan view:cache
systemctl restart apache2
check_command "Clearing caches and restarting services"

log_message "Deployment completed successfully"

# Rollback function
rollback() {
    log_message "Rolling back to previous version"
    if [ -d "${BACKUP_DIR}/$(date +"%F-%T")" ]; then
        mv ${DEPLOY_DIR} ${ROLLBACK_DIR}
        mv ${BACKUP_DIR}/$(date +"%F-%T") ${DEPLOY_DIR}
        systemctl restart apache2
        log_message "Rollback completed"
    else
        log_message "No backup found for rollback"
    fi
}
