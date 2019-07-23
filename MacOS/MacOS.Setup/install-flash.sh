#!/bin/sh -x
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#   UpdateFlash.sh -- Installs or updates Adobe Flash Player
#
#
####################################################################################################
#
#   14-Dec-2017 (bkp): Updated to support $0 with spaces in path
#   Peter Loobuyck grabbed bits from the net 
#
####################################################################################################


dmgfile="flash.dmg"
volname="Flash"
logfile="/Library/Logs/jamf.log"
srcPath=`/usr/bin/dirname "${0}"`

#
    latestver=`/usr/bin/curl --connect-timeout 8 --max-time 8 -sf "http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml" 2>/dev/null | xmllint --format - 2>/dev/null | awk -F'"' '/<update version/{print $2}' | sed 's/,/./g'`
    # Get the version number of the currently-installed Flash Player, if any.
    shortver=${latestver:0:2}
    url="https://fpdownload.adobe.com/get/flashplayer/pdc/"$latestver"/install_flash_player_osx.dmg"
    currentinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
    #else
    #   currentinstalledver="none"
    #fi
    # Compare the two versions, if they are different of Flash is not present then download and install the new version.
    if [ "${currentinstalledver}" != "${latestver}" ]; then
        /bin/echo "`date`: Current Flash version: ${currentinstalledver}" >> ${logfile}
        /bin/echo "`date`: Available Flash version: ${latestver}" >> ${logfile}
        /bin/echo "`date`: Downloading newer version." >> ${logfile}
        /usr/bin/curl -s -o "${srcPath}/${dmgfile}" $url
        /bin/echo "`date`: Mounting installer disk image." >> ${logfile}
        /usr/bin/hdiutil attach "${srcPath}/${dmgfile}" -nobrowse -quiet
        /bin/echo "`date`: Installing..." >> ${logfile}
        /usr/sbin/installer -pkg /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app/Contents/Resources/Adobe\ Flash\ Player.pkg -target / > /dev/null
        /bin/sleep 10
        /bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
        /usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
        /bin/sleep 10
        /bin/echo "`date`: Deleting disk image." >> ${logfile}
        /bin/rm "${srcPath}/${dmgfile}"
        newlyinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
        if [ "${latestver}" = "${newlyinstalledver}" ]; then
            /bin/echo "`date`: SUCCESS: Flash has been updated to version ${newlyinstalledver}" >> ${logfile}
        else
            /bin/echo "`date`: ERROR: Flash update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
            /bin/echo "--" >> ${logfile}
        fi
    # If Flash is up to date already, just log it and exit.       
    else
        /bin/echo "`date`: Flash is already up to date, running ${currentinstalledver}." >> ${logfile}
        /bin/echo "--" >> ${logfile}
    fi
