#!/bin/bash

VM=$1


if [[ -d /var/lib/libvirt/images/$VM ]]; then
    echo "cloning..."
    virt-clone --original centos --name $VM --file=/var/lib/libvirt/images/$VM/$VM.qcow2
else
    echo "directory does NOT exist, creating it now"
    mkdir /var/lib/libvirt/images/$VM
    echo "Cloning centos VM"
    virt-clone --original centos --name $VM --file=/var/lib/libvirt/images/$VM/$VM.qcow2
    echo
    echo "changing hostname on $VM"
    virt-customize -d $VM --hostname=$VM.zuelly.lcl
    echo
    echo "starting $VM"
    virsh start $VM
fi
