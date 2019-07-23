#!/bin/bash
## Screen Savers Installer
## Version 2.0.1
## Created by Jayke Peters on 2018-04-11
## MIT License

## Quick Execution
## curl -fkL https://raw.githubusercontent.com/jaykepeters/Scripts/master/install-screen_savers.sh | sh

## Set Variables
username=$(stat -f%Su /dev/console)
homedir=$(eval echo "~${username}")
DESTINATION=/Library/Screen\ Savers
logfile=~/Library/Logs/install-screen_savers.log
num=0

usercheck() {
	if [ "$EUID" -ne 0 ]; then
		DESTINATION="$homedir""$DESTINATION"
	else
		DESTINATION=/System"$DESTINATION"
fi
}

initialize() {
# Create the log file
touch ${logfile}
echo 'Installation Started on $(date)'

# Tell the installer the current progress
echo "PROGRESS:$num"
echo 'Installer Initialized' >> ${logfile}
}

## Check if Online
internet() {
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    online=true
else
	echo
	osascript -e 'display dialog "The connection is down. Please try again later."'
	exit 0
fi
}

start() {
	usercheck
	initialize
	internet
	echo $homedir

}

## Start the Installation
start

## Download ZIP file
progress=5
echo 'Downloading ZIP...'
echo 'Downloading ZIP...' >> ${logfile}

curl -Lo "/tmp/Screen Savers.zip" https://github.com/jaykepeters/Screen-Savers/raw/master/Screen%20Savers.zip --silent > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Download Success icon
progress=5
echo 'Downloading Installer Support Files...'
curl -Lo "/tmp/Success.pdf" https://github.com/jaykepeters/Screen-Savers/raw/master/Success.pdf --silent > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Wait
progress=5
echo 'Processing...'
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Unzip files to temp
progress=10
echo 'Unzipping files to /tmp...'
unzip -oqq "/tmp/Screen Savers.zip" -d /tmp > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Move Screen Savers to their folder
echo 'Moving files into place...'
for f in /tmp/Screen\ Savers/*
do
	rsync -av "${f}" "$DESTINATION" > /dev/null
	num=$(($num + 2))
	echo "PROGRESS:$num"
	echo "$num% Complete"
done

## Remove ZIP 
progress=10
echo 'Removing File 1 of 3...'
rm -R "/tmp/Screen Savers.zip" > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Remove the Screen Saver folder
progress=5
echo 'Removing file 2 of 3...'
rm -R "/tmp/Screen Savers" > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Remove the macOS folder
progress=5
echo 'removing file 3 of 3...'
rm -R "/tmp/__MACOSX" > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Wait
progress=5
echo 'Processing'
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Display Success Notification
progress=5
echo 'Displaying Success Alert...'
afplay "/tmp/burn complete.aif" &
osascript -e 'tell application "System Events"
	display dialog "Your Screen Savers have been successfully installed." buttons {"Thanks!"} default button {"Thanks!"} with icon {"/tmp/success.pdf"} giving up after 3
end tell' > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Open the Screensaver Pane
progress=5
echo 'Opening System Preferences...'
osascript -e 'tell application "System Preferences"
	activate
	reveal anchor "ScreenSaverPref" of pane "com.apple.preference.desktopscreeneffect"
end tell' > /dev/null
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num"

## Remove the success icon
progress=5
echo 'Cleaning Up'
rm -R /tmp/Success.pdf > /dev/null
num=$(($num + $progress))
num=$(($num + $progress))
echo "$num% Complete"
echo "PROGRESS:$num" 1<&2

## Exit the Installer
echo 'Install Screensavers Complete! Exiting...'
echo 'QUITAPP\n'
