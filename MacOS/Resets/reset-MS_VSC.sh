#!/bin/bash
## Reset MS VSC (Mac) - v1.2.6
## MIT License 
## Copyright 2018 Jayke Peters

## Quick Execution
# curl -fkl https://raw.githubusercontent.com/jaykepeters/Scripts/master/reset-MS_VSC.sh | bash

## Set Global Variables
start=$SECONDS
username=$(stat -f%Su /dev/console)
version="1.2.4"
me=$(basename "$0")
logfile=~/Library/Logs/$me.log
today=$(date)

## Declare Arrays
pids=($(pgrep Electron))
list=(
~/Library/Preferences/com.microsoft.VSCode.helper.plist 
~/Library/Preferences/com.microsoft.VSCode.plist 
~/Library/Caches/com.microsoft.VSCode
~/Library/Caches/com.microsoft.VSCode.ShipIt/
~/Library/Application\ Support/Code
~/Library/Saved\ Application\ State/com.microsoft.VSCode.savedState/
~/.vscode/
   )

## THIS IS WHERE ALL THE FUNCTIONS SHALL GO; DO NOT MODIFY BEYOND THIS POINT!!!
# Initialize the log file
initlog() {
   echo $me started by USER $username on $today > $logfile
   echo TASK >> $logfile
}
   
# Attempt to Kill Visual Studio Code
killapp() {
    for pid in "${pids[@]}"; do
        echo -e 'killing PID no:\t' $pid >> $logfile
        kill -9 $pid
    done    
}

# Iterate and remove all app files... (except for a few)
removefiles() {
for item in "${list[@]}"; do
    echo removing $item >> $logfile
    rm -Rif "$item" >> $logfile
done
}

version() {
    clear
    echo -e 'VERSION:\t' $version
    exit 0
}

main() {
    initlog
    killapp > /dev/null 2>&1
    removefiles
    duration=$(( SECONDS - start ))
    echo Completed in $duration Seconds >> $logfile
}

verbose() {
    main
    cat $logfile
    sleep 5
    open $logfile
}

help () {
    clear
    echo -e 'USAGE:\n'
    echo "Display the script's version:"
    echo "$me --Version | -V"
}
## Check for USER Input
if [[ $# = 0 ]]; then
    main
else
    while [[ $# > 0 ]]; do
        case "$1" in
            *Version|*version|*V|*v)
            version
            ;;
            *verbose|*Verbose|*VB|*vb)
            verbose
            ;;
            *HELP|*help|*H|*h)
            help
            ;;
        esac
        shift
        done
fi

