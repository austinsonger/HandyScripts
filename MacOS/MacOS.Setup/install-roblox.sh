#!/bin/bash
dmg="/tmp/roblox.dmg"
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
DESTINATION=/Applications
app="Roblox.app"
DESTINATION="$HOME_DIR""$DESTINATION"

curl -sLo "$dmg" https://setup.rbxcdn.com/mac/version-9a3605e064be477b-Roblox.dmg

hdiutil attach -nobrowse -noverify "$dmg"

# Find the Mounted DMG
volume="/Volumes/""$(ls /Volumes/ | grep 'Roblox' | head -n 1)"

# Move roblox to the applications folder
ditto --rsrc "$volume"/"$app" "$DESTINATION"/"$app"

# Unmount the DMG
hdiutil detach "$volume"

# Delete the DMG
rm -Rif "$dmg"

# Permissions
chown $USERNAME "$DESTINATION"/"$app"

# Open the app
/usr/bin/sudo -u $USERNAME open -a "$DESTINATION"/"$app"
