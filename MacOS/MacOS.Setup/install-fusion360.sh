#!/bin/bash
## Install Fusion 360 Version 1.0

# Kill all open Autodesk Applications and wait
pkill Fusion 360*
pkill Autodesk*
sleep 5

# Download the DMG from Autodesk
curl -Lo /tmp/fusion.dmg https://dl.appstreaming.autodesk.com/production/installers/Fusion%20360%20Client%20Downloader.dmg --silent

# Mount the Volume
hdiutil attach -nobrowse -noverify /tmp/fusion.dmg > /dev/null

# Perform the Silent Install
/Volumes/Autodesk\ Client\ Downloader/Right-click\ \>\ Open\ to\ Install.app/Contents/MacOS/streamer -p deploy --quiet

# Unmount the Volume
hdiutil detach /Volumes/Autodesk\ Client\ Downloader > /dev/null

# Remove the DMG
rm /tmp/fusion.dmg
