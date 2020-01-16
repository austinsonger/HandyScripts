#!/bin/bash

# Author: Stephen Haywood
# Last Modified: 2016-10-13
#
# Copyright AppSec Consulting, Inc.
# All rights reserved.

# Apply the latest updates to the host box.
sudo apt-get update
sudo apt-get -y upgrade

# Configure the Docker APT key and repos.
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo sh -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list'
sudo apt-get update

# Install and start docker
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual docker-engine
sudo service docker start

# Install Kali Top 10 Metapackage
sudo docker pull kalilinux/kali-linux-docker
sudo docker run kalilinux/kali-linux-docker sh -c 'apt-get update; apt-get -y install kali-linux-top10'
sudo docker commit $(sudo docker ps -lq) kali:v1

echo "To access the Kali server run 'sudo docker run -it kali:v1 /bin/bash'."
echo "To save changes to the server run 'sudo docker commit $(sudo docker ps -lq) kali:vN', where N is a number"
echo "To run the saved server use 'sudo docker run -it kali:vN /bin/bash'."