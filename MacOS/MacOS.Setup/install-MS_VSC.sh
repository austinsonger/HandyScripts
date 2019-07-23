#!/bin/bash
# Install MS VSC - v1.0.0
## Set Global Variables
TEMP_DIR=/tmp
ZIP_NAME="VSC.zip"
APP_NAME="Visual Studio Code.app"
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
DESTINATION=/Applications

## Set Array of files

# Determine where to put the files
CHECK_USER() {
	if [ "$EUID" -ne 0 ]; then
		DESTINATION="$HOME_DIR""$DESTINATION"
     fi
}

CHECK_USER

# Download the latest version of VSC as a *.ZIP file from Microsoft
curl -o $TEMP_DIR/$ZIP_NAME -O -J -L https://go.microsoft.com/fwlink/?LinkID=620882 --silent

# Unzip the file
unzip -oqq "$TEMP_DIR/$ZIP_NAME" -d $DESTINATION
