#!/bin/bash
## Install Skype Version 1.0.1 by Jayke Peters
## This script will install Skype on your Mac

# Download the DMG to a temporary location
curl -Lo /tmp/Skype.dmg https://go.skype.com/mac.download

# Silently mount and hide the DMG from the user(s)
hdiutil attach -noverify -nobrowse /tmp/Skype.dmg

# Copy the application to the applications folder
ditto -rsrc /Volumes/Skype/Skype.app /Applications/Skype.app

# Eject the Volume from the system
hdiutil detach /Volumes/Skype

# Remove the DMG from the temporary location
rm /tmp/Skype.dmg
