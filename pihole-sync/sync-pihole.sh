#!/bin/bash

clush -n -w pihole2 systemctl stop pihole-FTL

clush -n -w pihole2 --copy /etc/pihole/pihole-FTL*
clush -n -w pihole2 --copy /etc/pihole/dns-servers.conf
clush -n -w pihole2 --copy /etc/pihole/setupVars.conf

clush -n -w pihole2 systemctl start pihole-FTL

