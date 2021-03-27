#!/bin/bash

interf=ens160
ADDR=`/sbin/ip a | grep 'inet' | awk '{print $2}' | sed -n 3p | cut -c 1-13`
#1STO=`/sbin/ip a | grep 'inet' | awk '{print $2}' | sed -n 3p | cut -c 1-3`
#2NDO=`/sbin/ip a | grep 'inet' | awk '{print $2}' | sed -n 3p | cut -c 5-7`
#3RDO=`/sbin/ip a | grep 'inet' | awk '{print $2}' | sed -n 3p | cut -c 9`
#4THO=`/sbin/ip a | grep 'inet' | awk '{print $2}' | sed -n 3p | cut -c 11-13`
HOST=`hostname`
DOMAIN=$HOST.zuelly.lcl
NSHOST=ns1.zuelly.lcl
nsupdate << EOF
server $NSHOST
zone zuelly.lcl
update add $DOMAIN 600 A $ADDR
send
EOF

