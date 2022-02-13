#!/bin/bash

ADDR=`/usr/sbin/ip a | grep 'inet' | awk '{print $2}' | sed -n 2p | cut -c 1-14`
HOST=`hostname -s`
DOMAIN=$HOST.xlab.lcl
NSHOST=dns100.xlab.lcl
nsupdate << EOF
server $NSHOST
zone xlab.lcl
update add $DOMAIN 600 A $ADDR
send
EOF
