#!/bin/bash
logfile="/var/log/pihole-sync/sync.$(date +%Y-%m-%d_%H:%M).log"
exec 1>> > (ts '%Y-%m-%d %H:%M:%S]' > "$logfile") 2>&1

echo "stopping pihole on pihole2"
clush -n -g pihole2 systemctl stop pihole-FTL

echo "copying config files from local box to pihole2"
clush -n -g pihole2 --copy /etc/pihole/pihole-FTL*
clush -n -g pihole2 --copy /etc/pihole/*.list
clush -n -g pihole2 --copy /etc/pihole/dns-servers.conf
clush -n -g pihole2 --copy /etc/pihole/setupVars.conf

echo "starting pihole-FTL on pihole2"
clush -n -g pihole2 systemctl start pihole-FTL

echo "DONE"
