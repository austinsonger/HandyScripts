#!/bin/bash
#
#Author: Austin Songer
########################

sudo apt update -y
sudo apt list --upgradable -a
sudo apt upgrade -y
sudo dpkg --configure -a
sudo apt install -f
sudo apt update --fix-missing
sudo apt --fix-broken install -y

# Remove old package lists
rm -rf /var/lib/apt/lists/*
apt-get update

# Clean
sudo apt autoremove --purge -y
sudo apt autoclean -y
sudo rm -rf /home/$USER/.local/share/Trash/*
sudo find /tmp/ -type f -mtime +1 -exec sudo rm {} \;
sudo find /tmp/ -type f -atime +1 -exec sudo rm {} \;
sudo apt remove -y
sudo apt clean -y
sudo apt clean all -y
sudo rm  /home/$USER/.bash_history
sudo rm  /home/$USER/.local/share/user-places.xbel.bak
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
sudo rm -rf /var/crash
sudo rm -rf /home/$USER/.cache/evolution/*
sudo rm -rf /home/$USER/.cache/thumbnails/*
sudo rm -rf /home/$USER/.cache/pip
find /home/$USER/.cache/ -type f -mtime +1 -exec rm {} \;
find /home/$USER/.cache/ -type f -atime +1 -exec rm {} \;
sudo find /var/backups/ -type f -mtime +1 -exec sudo rm {} \;
sudo find /var/backups/ -type f -atime +1 -exec sudo rm {} \;
sudo find /var/log/ -type f -mtime +1 -exec sudo rm {} \;
Sudo find /var/log/ -type f -atime +1 -exec sudo rm {} \;
sudo find /var/cache/apt/archives/ -type f -mtime +1 -exec sudo rm {} \;
sudo find /var/cache/apt/archives/ -type f -atime +1 -exec sudo rm {} \;



## Memory Clean
# to look up free memory
free -h
# clean ram cmds
sync; echo 1 > /proc/sys/vm/drop_caches
sync; echo 2 > /proc/sys/vm/drop_caches
sync; echo 3 > /proc/sys/vm/drop_caches
# to check free memory again
free -h

