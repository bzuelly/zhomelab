#!/bin/bash

clush -n -g pihole2 systemctl stop pihole-FTL

clush -n -g pihole2 --copy /etc/pihole/pihole-FTL*
clush -n -g pihole2 --copy /etc/pihole/*.list
clush -n -g pihole2 --copy /etc/pihole/dns-servers.conf
clush -n -g pihole2 --copy /etc/pihole/setupVars.conf

clush -n -g pihole2 systemctl start pihole-FTL

