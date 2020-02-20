#!/bin/bash
sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo "ssh-rsa RSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEY ubuntu" >> /home/ubuntu/.ssh/authorized_keys


sudo apt update
sudo apt -y install curl nginx unzip
sudo apt -y install php7.2 php7.2-fpm php7.2-common php7.2-gmp php7.2-curl php7.2-soap php7.2-bcmath php7.2-intl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-cli php7.2-zip



sudo apt -y install php-dev libmcrypt-dev php-pear
sudo echo '' | pecl channel-update pecl.php.net
sudo echo '' | pecl install mcrypt-1.0.1

sudo systemctl restart php7.2-fpm


sudo  bash -c 'cat <<EOF > /etc/nginx/sites-available/magento2
upstream fastcgi_backend {
     server  unix:/run/php/php7.2-fpm.sock;
 }

 server {

     listen 80;
     server_name domain.com mage2.mydomain.net;
     set ''\$MAGE_ROOT'' /var/www/html/magento2;
     include /var/www/html/magento2/nginx.conf.sample;
 }
EOF'

sudo ln -s /etc/nginx/sites-available/magento2 /etc/nginx/sites-enabled
sudo systemctl restart nginx


sudo apt -y install mariadb-server mariadb-client

sudo mysql_secure_installation <<EOF
y
MYSQLROOTPASSWORD
MYSQLROOTPASSWORD
y
y
y
y
EOF



sudo systemctl restart mariadb.service
sudo mysql -u root -e "CREATE DATABASE magento2;"
sudo mysql -u root -e "CREATE USER 'mageplaza'@'localhost' IDENTIFIED BY 'MYSQLPASSWORD';"
sudo mysql -u root -e "GRANT ALL ON magento2.* TO 'mageplaza'@'localhost' IDENTIFIED BY 'MYSQLPASSWORD' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"


sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
sudo cd /tmp
sudo wget https://github.com/magento/magento2/archive/2.3.tar.gz
sudo tar -pzxvf 2.3.tar.gz -C /var/www/html/
sudo mv /var/www/html/magento2-2.3 /var/www/html/magento2


#sudo mkdir /home/ubuntu/.composer/
sudo bash -c "cat <<EOF > /home/ubuntu/.composer/auth.json
{
    \"http-basic\": {
        \"repo.magento.com\": {
            \"username\": \"REPOUSERNAMEREPOUSERNAME\",
            \"password\": \"REPOPASSWORDREPOPASSWORD\"
        }
    }
}

EOF"

cd /var/www/html/magento2
sudo composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition magento
sudo composer install
sudo chown -R www-data:www-data /var/www/html/magento2/
sudo chmod -R 755 /var/www/html/magento2/

sudo service nginx restart
