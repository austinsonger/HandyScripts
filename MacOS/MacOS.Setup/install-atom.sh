#!/bin/bash
## Install Atom - v1.0.0
## Set Global Variables
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
link="https://atom.io/download/mac"
TEMP_DIR=/tmp
ZIP_NAME="atom.zip"
DESTINATION=/Applications

# Download ZIP
curl -o $TEMP_DIR/$ZIP_NAME -O -J -L "$link" --silent

# Determine Install Directory
if [ "$EUID" -ne 0 ]; then
	DESTINATION="$HOME_DIR""$DESTINATION"
fi

# Unzip File
unzip -oqq "$TEMP_DIR/$ZIP_NAME" -d $DESTINATION

# Remove Download
rm -Rif $TEMP_DIR/$ZIP_NAME
