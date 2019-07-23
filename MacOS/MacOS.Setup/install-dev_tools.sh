#!/bin/bash
# Install Dev Tools
## Set Global Variables
TEMP_DIR=/tmp
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")

# Setup Path
curl -sSL https://raw.githubusercontent.com/jaykepeters/Scripts/Deployment/Setup/setup-path.sh | bash

# Install Visual Studio Code
curl -sSL https://raw.githubusercontent.com/jaykepeters/Scripts/Deployment/Installs/install-MS_VSC.sh | bash

# Add link to desktop
ln -s "$HOME_DIR"/"Applications"/"Visual Studio Code.app" "$HOME_DIR"/"Desktop"

# Install Hyper 
curl -sSL https://raw.githubusercontent.com/jaykepeters/Scripts/Deployment/Installs/install-hyper.sh | bash

# Install Screen Savers
curl -sSL https://raw.githubusercontent.com/jaykepeters/Scripts/Deployment/Installs/install-screen_savers.sh | bash
osascript -e 'display alert "New Screen Savers Installed" giving up after 2' &>/dev/null &

# Hand Over Installation to DevTools
curl -sSL https://raw.githubusercontent.com/jaykepeters/unio/master/bin/DevTools | bash &>/tmp/DevTools.log
