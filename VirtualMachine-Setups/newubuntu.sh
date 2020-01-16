sudo apt update -y
sudo apt list --upgradable -a
sudo apt upgrade -y
sudo dpkg --configure -a
sudo apt install -f
sudo apt update --fix-missing
sudo apt --fix-broken install -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sudo apt install ubuntu-restricted-extras -y
sudo add-apt-repository universe
sudo apt install gdm3 -y
sudo sed -i "s/^#  AutomaticLoginEnable = true/  AutomaticLoginEnable = true/" /etc/gdm3/custom.conf
sudo sed -i "s/^#  AutomaticLogin = user1/  AutomaticLogin = root/" /etc/gdm3/custom.conf

# Remove old package lists
rm -rf /var/lib/apt/lists/*
apt-get update

## RDP ##
#########
sudo apt install xfce4 -y
sudo apt install xrdp -y 
sudo adduser xrdp ssl-cert 
echo xfce4-session >~/.xsession
# sudo nano /etc/xrdp/xrdp.ini
# exec startxfce4
# nano /etc/xrdp/startwm.sh
# #!/bin/sh
# if [ -r /etc/default/locale ]; then
#   . /etc/default/locale
#   export LANG LANGUAGE
# fi
#
# startxfce4
# sudo systemctl restart xrdp


# SHELL #############
# wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
# chsh -s `which zsh`
# cd ~/.oh-my-zsh/themes
# wget https://raw.githubusercontent.com/dikiaap/dotfiles/master/.oh-my-zsh/themes/oxide.zsh-theme
# wget https://raw.githubusercontent.com/jacqinthebox/arm-templates-and-configs/master/fino-clean.zsh-theme
# wget https://raw.githubusercontent.com/agnoster/agnoster-zsh-theme/master/agnoster.zsh-theme
# wget https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme


mkdir -p ~/Downloads/gitrepos && cd ~/Downloads/gitrepos
wget https://dl.google.com/go/go1.12.9.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.12.9.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y nodejs npm

sudo apt install python-virtualenv python-dev python3-distutils
sudo apt install python3-pip
sudo pip install virtualenvwrapper

# git config --global user.name <username>
# git config --global user.email <name@example.com>

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
