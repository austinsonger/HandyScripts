#

##

# Verify all Apple provided software is current 

softwareupdate -l 

# Enable Auto Update

defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 

# Enable app update installs 

defaults read /Library/Preferences/com.apple.commerce AutoUpdate

# Enable system data files and security update installs 

defaults read /Library/Preferences/com.apple.SoftwareUpdate | egrep '(ConfigDataInstall|CriticalUpdateInstall)'

# Enable macOS update installs 

defaults read /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired

## System Preferences

# Turn off Bluetooth, if no paired devices exist 

defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState

# Show Bluetooth status in menu bar 

defaults read com.apple.systemuiserver menuExtras | grep Bluetooth.menu


# Enable "Set Time and Data Automatically"

sudo systemsetup -getusingnetworktime 

# Ensure time set is within appropriate limits 

sudo systemsetup -getnetworktimeserver 

# Set an inactivity interval of 20 minutes or less for the screen saver 

defaults -currentHost write com.apple.screensaver idleTime -int 1200

# Secure screen saver corners 

defaults read ~/Library/Preferences/com.apple.dock | grep -i corner

# Quick Lock Out - Hot Corners

defaults write ~/Library/Preferences/com.apple.dock wvous-tr-corner -int 6










