#!/bin/bash
## Install Sublime Text - v1.0.2
## Set Global Variables
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
link="http://www.sublimetext.com/3"
TEMP_DIR=/tmp
DMG="Sublime_Text.dmg"
file="$TEMP_DIR"/"$DMG"
volume="/Volumes/Sublime Text"
app="Sublime Text.app"
DESTINATION=/Applications

# Find the Latest Download Link
link=$(curl -s "$link" grep -Eo '<a [^>]+>' | grep -Eo '"[^\"]+"' | cut -d '"' -f2 | grep "dmg")

# Download DMG
curl -sLo "$file" -O -J -L "$link"

# Mount DMG
hdiutil attach -nobrowse -noverify "$file"

# Determine Install Directory
if [ "$EUID" -ne 0 ]; then
	DESTINATION="$HOME_DIR""$DESTINATION"
fi

# Install the Application
ditto --rsrc "$volume"/"$app" "$DESTINATION"/"$app"

# Unmount DMG
hdiutil detach "$volume" > /dev/null

# Remove DMG
rm -Rif "$file"
