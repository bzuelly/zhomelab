#!/bin/bash

qemu-img create -f qcow2 /var/lib/libvirt/images/rocky8.qcow2 20G

sudo virt-install --virt-type kvm --name rocky-linux-8 \
  --memory=1024 \
  --disk /var/lib/libvirt/images/rocky8.qcow2,format=qcow2 \
  --vcpus=2 \
  --os-type=generic \
  --location /tmp/Rocky-8.4-x86_64-minimal.iso \
  --network bridge=br10 \
  --graphics none \
  --noautoconsole \
  --extra-args 'console=ttyS0,115200n8 serial'
