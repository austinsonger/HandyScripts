#!/bin/bash
## Login Banner Update Script
## Inspired by https://www.daveperrett.com/articles/2007/03/27/change-the-ssh-login-message/
## Define Global Variables
me=`basename "$0"`
LOGFILE="/etc/$me.log"
RETAIN_NUM_LINES=10
## --------------------- ##
bannerSource="https://raw.githubusercontent.com/jaykepeters/UniPi/master/banners/vpn"
bannerConfig="/etc/ssh/sshd_config"
LINE1="# SSH Login Message"
LINE2="Banner /etc/banner"

## Declare Functions
init() {
    clearShell() {
        clear
    }

    isSilent() {
        if [[ "$1" == "--silent" ]]; then
            SILENT=true
        fi
    }

    logSetup() {
        TMP=$(tail -n $RETAIN_NUM_LINES $LOGFILE 2>/dev/null) && echo "${TMP}" > $LOGFILE
        exec > >(tee -a $LOGFILE)
        exec 2>&1
    }

    # Clear Shell
    clearShell
    
    # Check for Input
    isSilent

    # Setup Logging
    logSetup
}

message() {
    echo "[$(date --rfc-3339=seconds)]: $*" >> $LOGFILE
    echo "$1"
}

silently() {
  if $SILENT; then
    $1 &>/dev/null
  else
    $1
  fi
}

configCheck() {
    message "Checking Configuration..."
    addConfig() {
        message "Configuration Not Found..."
        message "Adding Configuration..."
        echo "" >> "${bannerConfig}"
        echo "$LINE1" >> "${bannerConfig}"
        echo "$LINE2" >> "${bannerConfig}"
        message "Configuration Added Successfully!"
    }

    updateMSG() {
        message "Updating Message..."
        silently "mkdir /etc/Downloads"
        silently "wget "$bannerSource""
        mv ./vpn /etc/banner
        message "Message Updated!"
    }

    if grep -Fxq "$LINE2" /etc/ssh/sshd_config
    then
       updateMSG
    else
        addConfig
        UpdateMSG
    fi
    message "Everything looks Good!"
}

## Declare Main Function
main() {
    init
    configCheck
}

## Start Me!!!
main
