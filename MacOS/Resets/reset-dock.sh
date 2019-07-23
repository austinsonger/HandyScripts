#!/bin/bash

## Reset Dock Version 1.2
## Created and tested by Jayke Peters on 03/23/2018. 
## Modified Apr 26
## Modified October 6
## Deployable via Centrify, JumpCloud, Jamf Pro and other solutions.

# Store the current user's username as a variable
currentuser=`stat -f "%Su" /dev/console`

# Reset the Dock
/usr/bin/sudo -u $currentuser /usr/bin/defaults delete com.apple.dock

# Refresh the Dock
/usr/bin/killall Dock

