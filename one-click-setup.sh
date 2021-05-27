#!/usr/bin/env bash
set -e
rm -rf /var/node
cd /var || return

echo "A. Configuring firewall."
iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
iptables -I INPUT -p tcp --dport 4000 -j ACCEPT
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp --dport 27017 -j ACCEPT

mkdir -p /etc/network/if-pre-up.d
echo "#\!/bin/bash\niptables-restore < /etc/iptables.rules" > /etc/network/if-pre-up.d/iptables
iptables-save | sudo tee -a /etc/iptables.rules >> /dev/null
chmod  +x /etc/network/if-pre-up.d/iptables

ufw allow 8000
ufw allow 4000
ufw allow 80
ufw allow 27017
ufw allow 443

printf "\n\n\n"
echo "B. Cloning from Github Source."
git clone https://github.com/ccarner/COMP90082-RS-2021.git
mv COMP90082-RS-2021 node
cd node|| exit
git checkout backend/develop


printf "\n\n\n"
echo "C. Installing dependencies."
apt update && apt -y install npm && apt -y install python3
npm install --global yarn
sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo apt-get install gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod


printf "\n\n\n"
echo "D. Installing admin API."
cd ServerAdminAPI|| exit
chmod +x install.sh
sh install.sh


printf "\n\n\n"
echo "E. Installing backend service."
cd ../backend|| exit
chmod +x install.sh
sh install.sh


printf "\n\n\n"
echo "F. Installing frontend service."
cd ../Front_end|| exit
chmod +x install.sh
sh install.sh


printf "\n\n\n"
echo "All Done!"
printf "\n"
systemctl status rsadmin | cat
printf "\n\n"
systemctl status rsrepo | cat
printf "\n\n"
systemctl status nginx | cat