#!/bin/bash
# Reset Hyper Terminal Script
# Set Global Variables
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")

# Is this being run as root?
CHECK_USER() {
    if [ "$EUID" -eq "0" ]; then
		    echo "Please run this script as: " $USERNAME
        exit 1
    fi
}

# Check the User
CHECK_USER

# Backup existing configuration
mv $HOME_DIR/.hyper.js $HOME_DIR/.hyper.js.bak

# Completion Message
echo "Reset!"
