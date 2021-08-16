#!/bin/bash


echo "Checking to see if rocky.qcow2 exists"
if [[ -f /var/lib/libvirt/images/rocky8.qcow2 ]]; then
    echo "rocky8.qcow2 exists, exiting now!"
    exit 0
else
    qemu-img create -f qcow2 /var/lib/libvirt/images/rocky8.qcow2 25G
fi


virt-install --virt-type kvm --name rocky8 --ram 2048 \
--disk /var/lib/libvirt/images/rocky8.qcow2,format=qcow2 \
--network bridge=br1 \
--os-type=linux \
--os-variant=rhl8.0 \
--graphics none \
--noautoconsole \
--location=/tmp/Rocky-8.4-x86_64-minimal.iso \
--extra-args 'console=ttyS0,115200n8 serial'

