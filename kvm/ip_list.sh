#!/bin/bash

virsh list --name | while read n 
do
  echo $n
  [[ ! -z $n ]] && virsh domifaddr --source agent $n | tail -n 3 | head -n 1
  echo ''
done
