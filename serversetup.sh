#!/bin/bash

# Server Setup Script
# This script sets up a Linux server with Apache, PHP, MariaDB, Node.js, and more.
# It also configures virtual hosts and SSL certificates for a given domain.
# Created by: Travis Ricker

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Function to check the success of a command and exit if it fails
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed. Exiting." 1>&2
        exit 1
    fi
}

# Update the system
apt update -y && apt upgrade -y
check_command "System update"

# Install required packages
apt install -y emacs apache2 software-properties-common wget git nodejs npm certbot python3-certbot-apache libapache2-mod-php
check_command "Package installation"

# Start and enable Apache
systemctl start apache2
systemctl enable apache2
check_command "Starting Apache"

# Add PHP repository and install PHP and required extensions
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-zip php8.1-dev php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath
check_command "Installing PHP"

# Install MariaDB
apt install -y mariadb-server
check_command "Installing MariaDB"
systemctl start mariadb
systemctl enable mariadb
check_command "Starting MariaDB"

# Install Yarn globally
npm install -g yarn
check_command "Installing Yarn"

# Install Composer globally
curl -sS https://getcomposer.org/installer | php
check_command "Downloading Composer"
mv composer.phar /usr/local/bin/composer

# Restart Apache to apply PHP installation
systemctl restart apache2
check_command "Restarting Apache"

# Ask for the domain name
echo "Please enter your domain name:"
read domain_name

# Define the configuration file path
config_file="/etc/apache2/sites-available/${domain_name}.conf"

# Write the configuration to the file
cat <<EOL | sudo tee $config_file
<VirtualHost *:80>
    ServerName ${domain_name}.com
    DocumentRoot /var/www/html/${domain_name}/public
    ServerAlias www.${domain_name}.com
    CustomLog /var/www/error.log combined
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =${domain_name}.com [OR]
    RewriteCond %{SERVER_NAME} =www.${domain_name}.com
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<VirtualHost *:80>
    ServerName admin.${domain_name}.com
    DocumentRoot /var/www/html/${domain_name}/backend/public
    CustomLog /var/www/${domain_name}-admin-error.log combined
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =admin.${domain_name}.com
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOL
check_command "Writing virtual host configuration"

# Enable the site and necessary Apache modules
a2ensite ${domain_name}.conf
a2enmod rewrite
systemctl reload apache2
check_command "Enabling site and Apache modules"

# Obtain SSL certificates for the domain
certbot --apache -d ${domain_name}.com -d www.${domain_name}.com -d admin.${domain_name}.com
check_command "Obtaining SSL certificates"

# Set up automatic renewal
mkdir -p /logs

# Add the cron job
(crontab -l; echo "0 0 */10 * * certbot renew >> /logs/certbot-cron.log 2>&1") | crontab -
check_command "Setting up cron job for certificate renewal"

# Modify Apache configuration to allow .htaccess overrides
apache_conf="/etc/apache2/apache2.conf"
cp ${apache_conf} ${apache_conf}.bak
sed -i '/<Directory \/var\/www\/>/{n;s/AllowOverride None/AllowOverride All/}' ${apache_conf}
systemctl restart apache2
check_command "Modifying Apache configuration"

# Output completion message
echo "Server setup completed successfully."
