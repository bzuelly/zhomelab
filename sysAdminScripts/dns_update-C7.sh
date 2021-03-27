#!/bin/bash

interf=ens192
###ADDR=`/sbin/ifconfig $interf | grep 'inet' | awk '{print $2}' | sed -n 1p`
ADDR=`/sbin/ip a | grep 'inet' | awk '{print $2}' | sed -n 3p | cut -c 1-13`
#1STO=`/sbin/ifconfig $interf | grep 'inet' | awk '{print $2}' | sed -n 1p | cut -c 1-3`
#2NDO=`/sbin/ifconfig $interf | grep 'inet' | awk '{print $2}' | sed -n 1p | cut -c 5-7`
#3RDO=`/sbin/ifconfig $interf | grep 'inet' | awk '{print $2}' | sed -n 1p | cut -c 9`
#4THO=`/sbin/ifconfig $interf | grep 'inet' | awk '{print $2}' | sed -n 1p | cut -c 11-13`
HOST=`hostname`
DOMAIN=$HOST.zuelly.lcl
NSHOST=ns1.zuelly.lcl
nsupdate << EOF
server $NSHOST
zone zuelly.lcl
update add $DOMAIN 600 A $ADDR
send
EOF

#update add $DOMAIN 600 A $ADDR


#update add $HOST 600 PTR $4THO.$3RDO.$2NDO.$1STO.zuely.lcl

