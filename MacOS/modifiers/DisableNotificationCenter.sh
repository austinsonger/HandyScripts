#!/bin/bash
# Disable Notification Center
## Set Global Variables
MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')

# Write to ByHost File
/usr/bin/defaults write ~/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "dndEnd" -float 1379
/usr/bin/defaults write ~/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "doNotDisturb" -bool FALSE
/usr/bin/defaults write ~/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "dndStart" -float 1380

# Stop Notification Center
launchctl stop com.apple.notificationcenterui.agent
killall SystemUIServer
sleep 1
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
