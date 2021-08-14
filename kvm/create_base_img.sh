#!/bin/bash


echo "Checking to see if centos.qcow2 exists"
if [[ -f /var/lib/libvirt/images/centos.qcow2 ]]; then
    echo "centos.qcow2 exists, exiting now!"
    exit 0
else
    qemu-img create -f qcow2 /var/lib/libvirt/images/centos.qcow2 10G
fi


virt-install --virt-type kvm --name centos --ram 1024 \
--disk /var/lib/libvirt/images/centos.qcow2,format=qcow2 \
--network bridge=br1 \
--os-type=linux \
--os-variant=centos7.0 \
--graphics none \
--noautoconsole \
--location=/tmp/CentOS-7-x86_64-Minimal-2009.iso \
--extra-args 'console=ttyS0,115200n8 serial'

