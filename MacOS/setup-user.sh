#!/bin/bash

# Set Global Variables
currentUser=`ls -l /dev/console | cut -d " " -f4`

# Disable reopen in preview
defaults write com.apple.Preview NSQuitAlwaysKeepsWindows -bool false

# Disable QuickTime Re-Open
defaults write com.apple.QuickTimePlayerX NSQuitAlwaysKeepsWindows -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool YES; killall Dock &

# Disable iCloud Drive Saving
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable Crash Reporter
defaults write com.apple.CrashReporter DialogType none

# Enable path view in Finder
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES

# Make a recent applications folder in the Dock
defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'

# Disable verification of DMG's
defaults write com.apple.frameworks.diskimages skip-verify TRUE

# Disable the accidental Google Chrome swipe 
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE

# Disable photos from opening everytime an iOS device is plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

# Enable Battery Percentage
sudo -u $currentUser defaults write com.apple.menuextra.battery ShowPercent YES
sudo -u $currentUser killall SystemUIServer

# Disable Writing on Network Drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Force Screensaver Sleep to 0
defaults write com.apple.screensaver.plist askForPasswordDelay -int 0
