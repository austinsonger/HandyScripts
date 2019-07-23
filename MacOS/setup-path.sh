#!/bin/bash

## Set Global Variables
USERNAME=$(stat -f%Su /dev/console)
HOME_DIR=$(eval echo "~${username}")
bin_dir="$HOME_DIR/bin"
profile=$HOMEDIR".bash_profile"

## Test to see if there is already a bin directory
if [ ! -d $bin_dir ]; then
    mkdir $bin_dir
fi

## Hide the bin directory
chflags hidden $bin_dir

## CHANGE THE BINDIR
echo "export PATH=$bin_dir:$PATH" >> $profile