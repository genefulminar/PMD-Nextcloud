#!/bin/bash

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install required packages
sudo apt install -y apache2 mysql-server php php-{mysql,ldap,xml,mbstring,gd}

# Enable and start Apache and MySQL services
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable mysql
sudo systemctl start mysql

# Set MySQL root password (change 'your_root_password_here' to your desired password)
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_root_password_here'; FLUSH PRIVILEGES;"

# Create a new database for GLPI and a user with appropriate privileges
sudo mysql -u root -p -e "CREATE DATABASE glpi CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -u root -p -e "CREATE USER 'glpiuser'@'localhost' IDENTIFIED BY 'your_glpi_user_password_here';"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON glpi.* TO 'glpiuser'@'localhost'; FLUSH PRIVILEGES;"

# Download GLPI
cd /tmp
wget -O glpi.tar.gz https://github.com/glpi-project/glpi/releases/download/9.5.7/glpi-9.5.7.tgz

# Extract and move GLPI to the web server's document root
sudo tar -xvzf glpi.tar.gz -C /var/www/html/
sudo mv /var/www/html/glpi /var/www/html/glpi-install
sudo chown -R www-data:www-data /var/www/html/glpi-install

# Set up Apache virtual host
sudo tee /etc/apache2/sites-available/glpi.conf > /dev/null << EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/glpi-install
    ServerName glpi.example.com

    <Directory /var/www/html/glpi-install>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the virtual host and Apache modules
sudo a2ensite glpi
sudo a2enmod rewrite
sudo systemctl restart apache2

# Remove the installation directory for security purposes
sudo rm -rf /var/www/html/glpi-install

echo "GLPI installation completed. Access it at http://glpi.example.com (replace 'glpi.example.com' with your domain or IP address)."
