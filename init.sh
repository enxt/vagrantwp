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
sudo apt-get install -y make curl htop git-core vim mercurial

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


mysqlhost=localhost
mysqldb=vagrantwpdb
mysqluser=root
mysqlpass=
wptitle="Vagrant WP"
wpuser=admin
wppass=vagrant
wpemail=youremail@mail.com
siteurl=192.168.0.101

cd ~
wget http://wordpress.org/latest.tar.gz
tar zxf latest.tar.gz
cd wordpress/

wget -O /tmp/wp.keys https://api.wordpress.org/secret-key/1.1/salt

sed -e "s/localhost/"$mysqlhost"/" -e "s/database_name_here/"$mysqldb"/" -e "s/username_here/"$mysqluser"/" -e "s/password_here/"$mysqlpass"/" wp-config-sample.php > wp-config.php
sed -i '/#@-/r /tmp/wp.keys' wp-config.php
sed -i "/#@+/,/#@-/d" wp-config.php

mysql -u root -Bse "create database $mysqldb;"
curl -d "weblog_title=$wptitle&user_name=$wpuser&admin_password=$wppass&admin_password2=$wppass&admin_email=$wpemail" http://$siteurl/wp-admin/install.php?step=2

cd ../
mv wordpress/* /vagrant/www/

rmdir wordpress
rm latest.tar.gz
rm /tmp/wp.keys


echo -e "----------------------------------------"
echo -e "To work in your Wordpress project:\n"
echo -e "----------------------------------------"
echo -e "$ cd /vagrant/www"
echo -e
echo -e "----------------------------------------"
echo -e "Default Site: http://192.168.0.101"
echo -e "----------------------------------------"
