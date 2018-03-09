#!/bin/bash

while [ `lsblk -n | grep -c 'xvdh'` -ne 1 ]
do
  echo "Waiting for /dev/xvdh to become available"
  sleep 10
done

# /etc/fstab already configured in packer/ansbile
mount -a