#!/bin/bash

dir=~/.collections

mkdir $dir

sort –nk3 –t: /etc/passwd >> $dir/psswdUsers.art

egrep ':0+:' /etc/passwd >> $dir/psswdPrivUsers.art

find / -nouser -print >> $dir/orphanedFiles.art

ps –aux >> $dir/processList.art

crontab –u root –l   >> $dir/rootCrontab.art

cat /etc/crontab >> $dir/globalCrontab.art

ls /etc/cron.* >> $dir/globalCronListing.art

tar cvfz $dir/extraview.tar.gz /var/log

/usr/bin/find / -ctime -1 -print >> $dir/recentFiles.art

ps -ef >> $dir/processListWCLI.art

rpm –Va | sort >> $dir/modifiedBins.art

Lsof -i >> $dir/proccesesWithPorts.art

arp -a >> $dir/arpTable.art

tar -zcvf artDir.tar.gz $dir ~