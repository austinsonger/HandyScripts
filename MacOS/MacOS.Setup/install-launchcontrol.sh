#!/bin/bash
## Install LaunchControl - v1.0.0
## Set Global Variables
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
site="https://www.soma-zone.com/download/"
TEMP_DIR="/tmp"
ZIP_NAME="LC.tar.bz2"
DESTINATION=/Applications

# Find the latest download link
download=$(curl -s $site | grep -Eo "(files)/LaunchControl[a-zA-Z0-9./?=_-]*.bz2")
download="$site""$download"

# Download file
curl -o $TEMP_DIR/$ZIP_NAME -O -J -L "$download" --silent

# Determine Installation Directory
if [ "$EUID" -ne 0 ]; then
	DESTINATION="$HOME_DIR""$DESTINATION"
fi

# Install the Application
tar xvjf "$TEMP_DIR/$ZIP_NAME" -C $DESTINATION &>/dev/null

# Remove Temporary Files
rm -rif "$TEMP_DIR/$ZIP_NAME"