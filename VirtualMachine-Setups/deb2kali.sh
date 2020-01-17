apt-get -y update
gpg --keyserver pgpkeys.mit.edu --recv-key  ED444FF07D8D0BF6
apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys 7D8D0BF6
gpg --keyserver hkp://keys.gnupg.net --recv-key 7D8D0BF6
gpg -a --export ED444FF07D8D0BF6 | sudo apt-key add -
echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
apt list --upgradable
apt-get -y update && apt-get -y upgrade
apt-get -y --allow-unauthenticated install kali-archive-keyring
apt-get -y update
apt-get -y update
# apt-cache search kali-linux
apt-get -y install kali-linux-all
apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
reboot
