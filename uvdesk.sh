#!/bin/bash

# Update package list and install Apache2
sudo apt update
sudo apt install -y apache2

# Stop, start, and enable Apache2 service
sudo systemctl stop apache2.service
sudo systemctl start apache2.service
sudo systemctl enable apache2.service

# Install MariaDB
sudo apt update
sudo apt install -y mariadb-server mariadb-client

# Secure MariaDB installation
sudo mysql_secure_installation

# Create UVdesk database and user
sudo mysql -u root -p -e "CREATE DATABASE uvdesk;"
sudo mysql -u root -p -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'M@pagmalasakit';"
sudo mysql -u root -p -e "GRANT ALL ON uvdesk.* TO 'admin'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"

# Install PHP 7.4 and related modules
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install -y php7.4 libapache2-mod-php7.4 php7.4-common php7.4-gmp php7.4-curl php7.4-intl php7.4-mbstring php7.4-xmlrpc php7.4-mysql php7.4-gd php7.4-xml php7.4-imap php7.4-mailparse php7.4-cli php7.4-zip

# Configure PHP settings for Apache2
sudo sed -i 's/;date.timezone =/date.timezone = America\/Chicago/' /etc/php/7.4/apache2/php.ini

# Restart Apache2
sudo systemctl restart apache2.service

# Install Curl and Composer
sudo apt install -y curl git
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Create UVdesk directory and download UVdesk
sudo mkdir /var/www/uvdesk
sudo chown $USER:$USER /var/www/uvdesk
cd /var/www/uvdesk
composer clear-cache
composer create-project uvdesk/community-skeleton helpdesk-project

# Set permissions for UVdesk
sudo chown -R www-data:www-data /var/www/uvdesk/
sudo chmod -R 755 /var/www/uvdesk/

# Create Apache2 VirtualHost configuration for UVdesk
sudo tee /etc/apache2/sites-available/uvdesk.conf > /dev/null <<EOT
<VirtualHost *:80>
     ServerAdmin helpdesk.pmdmc.net
     DocumentRoot /var/www/uvdesk/helpdesk-project/public
     ServerName helpdesk.pmdmc.net
     ServerAlias helpdesk.pmdmc.net

     <Directory /var/www/uvdesk/helpdesk-project/public/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOT

# Enable Apache2 VirtualHost and mod_rewrite
sudo a2ensite uvdesk.conf
sudo a2enmod rewrite

# Restart Apache2
sudo systemctl restart apache2.service

# You can proceed with the UVdesk setup wizard by accessing your server domain name
# http://example.com/

echo "UVdesk setup is complete. Access your server domain name to proceed with the setup wizard."
