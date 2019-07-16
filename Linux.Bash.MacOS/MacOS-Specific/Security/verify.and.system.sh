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








