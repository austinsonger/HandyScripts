#

## Sharing

# Disable Remote Apple Events 

sudo systemsetup -getremoteappleevents 

sudo systemsetup -setremoteappleevents off 

# Disable Internet Sharing 

sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.nat | grep -i Enabled

# Disable Screen Sharing 

sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist 

# Disable Printer Sharing 

system_profiler SPPrintersDataType | egrep "Shared: Yes" 

# Disable Remote Login

sudo systemsetup -getremotelogin

sudo systemsetup -setremotelogin off


# Disable DVD or CD Sharing 

sudo launchctl list | egrep ODSAgent 

# Disable Bluetooth Sharing 

system_profiler SPBluetoothDataType | grep State

# Disable File Sharing 

sudo launchctl list | egrep AppleFileServer

grep -i array /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist

sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist 

sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist

# Disable Remote Management 

ps -ef | egrep ARDAgent

