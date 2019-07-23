#!/bin/bash
# Install Flux - v1.0.0
## Set Global Variables
TEMP_DIR=/tmp
ZIP_NAME="Flux.zip"
APP_NAME="FLux.app"
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
DESTINATION=/Applications

# Determine the correct Applications Folder
CHECK_USER() {
	if [ "$EUID" -ne 0 ]; then
		DESTINATION="$HOME_DIR""$DESTINATION"
     fi
}

CHECK_USER

# Download ZIP
curl -o $TEMP_DIR/$ZIP_NAME -O -J -L https://justgetflux.com/mac/Flux.zip --silent

# Unzip
unzip -oqq "$TEMP_DIR/$ZIP_NAME" -d $DESTINATION

# Remove ZIP
rm -Rif $TEMP_DIR/$ZIP_NAME
