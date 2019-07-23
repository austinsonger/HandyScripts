#!/bin/bash
# Install Hyper - v1.0.0
## Set Global Variables
TEMP_DIR=/tmp
ZIP_NAME="temp_download.zip"
APP_NAME="LearnTerm.app"
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
DESTINATION=/Applications

# Determine where to put the files
if [ "$EUID" -ne 0 ]; then
	DESTINATION="$HOME_DIR""$DESTINATION"
fi

# Download the latest version
curl -o $TEMP_DIR/$ZIP_NAME -O -J -L https://releases.hyper.is/download/mac --silent

# Check for Applications Directory
if [ ! -d "$DESTINATION" ]; then
    mkdir "$DESTINATION"
fi

# Unzip the file
unzip -oqq "$TEMP_DIR/$ZIP_NAME" -d $DESTINATION

# Remove temporary file
rm -rf $TEMP_DIR/$ZIP_NAME

# Rename to prevent blocking by I.T.
mv "$DESTINATION"/"Hyper.app" "$DESTINATION"/"$APP_NAME"

# Reset the Launch Pad
defaults write com.apple.dock ResetLaunchPad -bool true

# Add to dock?
dockutil="/tmp/dockutil"
curl -Lo $dockutil https://raw.githubusercontent.com/kcrawford/dockutil/master/scripts/dockutil --silent
chmod +x $dockutil
echo "$DESTINATION"/"$APP_NAME"
$dockutil --add "$DESTINATION"/"$APP_NAME"
rm $dockutil

# Add an alias to the desktop
ln -s "$DESTINATION"/"$APP_NAME" ~/Desktop
