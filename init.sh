#!/bin/bash
# Using Wheezy64 Debian

sudo apt-get update

#
# MySQL with root:<no password>
#
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server

#
# PHP
#
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-mysql

#
# Utilities
#
sudo apt-get install -y make curl htop git-core vim mercurial sendmail

#
# MySQL Configuration
# Allow us to Remote from Vagrant with Port
#
sudo cp /etc/mysql/my.cnf /etc/mysql/my.bkup.cnf
# Note: Since the MySQL bind-address has a tab cahracter I comment out the end line
sudo sed -i 's/bind-address/bind-address = 0.0.0.0#/' /etc/mysql/my.cnf

#
# Grant All Priveleges to ROOT for remote access
#
mysql -u root -Bse "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
sudo service mysql restart

#
# Composer for PHP
#
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#
# Apache VHost
#
cd ~
echo '<VirtualHost *:80>
        DocumentRoot /vagrant/www
</VirtualHost>

<Directory "/vagrant/www">
        Options Indexes Followsymlinks
        AllowOverride All
        #Require all granted
</Directory>' > vagrant

sudo mv vagrant /etc/apache2/sites-available
sudo a2enmod rewrite

#
# Update PHP Error Reporting
#
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php5/apache2/php.ini
sudo sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php5/apache2/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini 

#
# Reload apache
#
sudo a2ensite vagrant
sudo a2dissite 000-default
sudo service apache2 reload
sudo service apache2 restart

#
# Install WP-CLI
#
cd /usr/local/lib
if [ ! -e /usr/local/lib/wp-cli/bin/wp ]; then
  printf "\nInstalling wp-cli\n"
  git clone git://github.com/wp-cli/wp-cli.git /usr/local/lib/wp-cli
  cd /usr/local/lib/wp-cli
  composer install
else
  printf "\nSkip wp-cli installation, already available\n"
fi

#
# Link wp to the /usr/local/bin directory
#
sudo ln -sf /usr/local/lib/wp-cli/bin/wp /usr/local/bin/wp


#
# Set basic wordpress variables
#
mysqlhost=localhost
mysqldb=vagrantwpdb
mysqluser=root
mysqlpass=
wptitle="Vagrant WP"
wpuser=admin
wppass=vagrant
wpemail=youremail@mail.com
siteurl=192.168.0.101

#
# Creating database for wordpress
#
mysql -u root -Bse "CREATE DATABASE IF NOT EXISTS $mysqldb"

#
# Downloading, configuring and installing wordpress with WP-CLI
#
cd /vagrant/www
sudo wp core download --path=/vagrant/www --allow-root
sudo wp core config --dbname=$mysqldb --dbuser=$mysqluser --allow-root --extra-php <<PHP
define( "WP_DEBUG", true);
define( "WP_DEBUG_LOG", true);
PHP
sudo wp core install --url=$siteurl --quiet --title="$wptitle" --admin_name=$wpuser --admin_password=$wppass --admin_email=$wpemail --allow-root


#
# Final message
#
echo -e
echo -e "----------------------------------------"
echo -e "Installation is complete"
echo -e
echo -e "You can visit wordpress at: http://$siteurl"
echo -e "----------------------------------------"
