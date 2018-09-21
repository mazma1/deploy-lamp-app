#!/usr/bin/env bash

# script to install Apache, MySQL, PHP, and deploy Wordpress

# exit when a command fails
set -o errexit

# exit if previous command returns a non 0 status
set -o pipefail


export DEBIAN_FRONTEND="noninteractive"

USER=$(whoami)
SQL_ROOT_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/sql_root_password -H "Metadata-Flavor: Google")
DB_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/db_name -H "Metadata-Flavor: Google")
DB_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/db_password -H "Metadata-Flavor: Google")


# update available packages
update_packages() {
  echo 'About to update packages....'

  sudo apt update -y
  sudo apt-get upgrade -y

  echo 'Successfully updated packages.'
}


install_apache() {
  echo 'About to install Apache....'

  sudo apt-get install apache2 -y
  sudo systemctl start apache2.service

  echo 'Successfully installed Apache.'
}


install_mysql() {
  echo 'About to install MySQL....'

  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${SQL_ROOT_PASSWORD}"
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${SQL_ROOT_PASSWORD}"

  sudo apt-get install mysql-server -y

  echo 'Successfully installed MySQL.'
}


install_php() {
  echo 'About to install PHP and some extensions....'

  sudo apt-get install php -y
  sudo apt-get install -y php-{bcmath,bz2,intl,gd,mbstring,mcrypt,mysql,zip}
  sudo apt-get install libapache2-mod-php -y

  echo 'Successfully installed PHP.'
}


start_apache_mysql_on_boot() {
  sudo systemctl enable apache2.service
  sudo /lib/systemd/systemd-sysv-install enable mysql
}


restart_apache() {
  echo 'Restarting Apache to allow PHP run.....'

  sudo systemctl restart apache2.service

  echo 'Successfully restarted Apache.'
}


download_wordpress() {
  echo 'About to download Wordpress.....'

  # Download Wordpress package
  wget -c http://wordpress.org/latest.tar.gz
  tar -xzvf latest.tar.gz

  # move Wordpress files to /var/www/html/
  sudo apt-get install rsync -y
  sudo rsync -av wordpress/* /var/www/html/

  # remove apache default index.html page
  sudo rm /var/www/html/index.html

  # Set required permissions
  sudo chown -R www-data:www-data /var/www/html/
  sudo chmod -R 755 /var/www/html/

  echo 'Wordpress download complete.'
}


create_wordpress_db() {
  echo 'About to create Wordpress DB.....'

  sudo mysql -p="${SQL_ROOT_PASSWORD}" -u "root" -Bse "CREATE DATABASE $DB_NAME;
  GRANT ALL PRIVILEGES ON $DB_NAME.* TO '${USER}'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
  FLUSH PRIVILEGES;"

  echo 'Successfully created Wordpress DB.'
}


configure_wordpress() {
  echo 'About to configure Wordpress.....'

  sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

  #set database details with perl find and replace
  sudo perl -pi -e "s'database_name_here'"$DB_NAME"'g" /var/www/html/wp-config.php
	sudo perl -pi -e "s'username_here'"$USER"'g" /var/www/html/wp-config.php
	sudo perl -pi -e "s'password_here'"$DB_PASSWORD"'g" /var/www/html/wp-config.php

  sudo systemctl restart apache2.service 
  sudo systemctl restart mysql.service 

  echo 'Successfully configured Wordpress. DEPLOYMENT COMPLETE!'
}


main() {
  update_packages
  install_apache
  install_mysql
  install_php
  start_apache_mysql_on_boot
  restart_apache
  download_wordpress
  create_wordpress_db
  configure_wordpress
}

main "$@"
