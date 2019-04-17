#!/bin/bash

echo "Preparing server"

sudo apt-get update
sudo locale-gen ru_RU.UTF-8
sudo localectl set-locale LANG=ru_RU.UTF-8
sudo dpkg-reconfigure tzdata


# Nginx
sudo apt-get install nginx -y
sudo systemctl restart nginx
sudo systemctl enable nginx


# Certbot
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx


sudo certbot --nginx
# - Congratulations! Your certificate and chain have been saved at:
#    /etc/letsencrypt/live/fx.navi.cc/fullchain.pem
#    Your key file has been saved at:
#    /etc/letsencrypt/live/fx.navi.cc/privkey.pem
#    Your cert will expire on 2019-07-16. To obtain a new or tweaked
#    version of this certificate in the future, simply run certbot again
#    with the "certonly" option. To non-interactively renew *all* of
#    your certificates, run "certbot renew"
#  - Your account credentials have been saved in your Certbot
#    configuration directory at /etc/letsencrypt. You should make a
#    secure backup of this folder now. This configuration directory will
#    also contain certificates and private keys obtained by Certbot so
#    making regular backups of this folder is ideal.
#  - If you like Certbot, please consider supporting our work by:
#
#    Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
#    Donating to EFF:                    https://eff.org/donate-le


# Erlang

wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install erlang


# MongoDB (Ubuntu 18.04)

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo service mongod start
sudo systemctl enable mongod
