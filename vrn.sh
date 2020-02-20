#!/bin/bash

echo "ssh-rsa RSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEYRSAKEY ubuntu" >> /home/ubuntu/.ssh/authorized_keys


sudo apt-get update
sudo apt-get -y install varnish

sudo mv /etc/varnish/default.vcl /etc/varnish/old.default
#sudo wget http://configs.mydomain.net/varnish.cfg -O /etc/varnish/default.vcl


sudo sed -i s/6081/80/g /etc/default/varnish
sudo sed -i s/6081/80/g /lib/systemd/system/varnish.service

sudo systemctl daemon-reload
sudo systemctl restart varnish

