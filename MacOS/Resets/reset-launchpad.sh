#!/bin/bash

## Reset Launchpad Version 1.0.1
## VERSION 1 Created and tested by Jayke Peters on 03/23/2018. 
## VERSION 1.0.1:         DESCRIPTION CHANGED BY JP on 6/16/18
## VERSION 1.0.2          DESCRIPTION CHANGED BY JP on 10/6/18
## Deployable via Centrify, JumpCloud, Jamf Pro and other solutions.
## Jamf Pro JSS supposedly sets the $1, $2, $3 parameters upon script deployment.

# Store the current user's username as a variable
currentuser=`stat -f "%Su" /dev/console`

# Reset the Launchpad
/usr/bin/sudo -u $currentuser /usr/bin/defaults write com.apple.dock ResetLaunchPad -bool true

# Refresh the Dock & Launchpad
/usr/bin/killall Dock

