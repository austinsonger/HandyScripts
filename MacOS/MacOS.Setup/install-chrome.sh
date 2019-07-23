#!/bin/bash
## Copyright 2018 Jayke Peters.
## Install-Chrome Version 1.0.2

## Set Variables
# Get the current user's username
username=$(stat -f%Su /dev/console)

# Get the current user's home directory
homedir="/"

## Check to see if the script is running as root
if [ "$EUID" -ne 0 ]; then
	homedir="$(eval echo "~${username}")"
fi

install-chrome (){
# Download the DMG from Google
curl -Lo /tmp/Google\ Chrome.dmg https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg

# Mount the Volume
hdiutil attach -nobrowse -noverify /tmp/Google\ Chrome.dmg

# Move the Application to the Applications folder
ditto --rsrc /Volumes/Google\ Chrome/Google\ Chrome.app "${homedir}/Applications/Google Chrome.app"

# Eject the Volume
hdiutil detach /Volumes/Google\ Chrome

# Remove the DMG
rm /tmp/Google\ Chrome.dmg
}

## Perform the installation
install-chrome

# GitHub won't sync :(
