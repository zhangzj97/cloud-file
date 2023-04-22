#!/bin/bash -i

IPADDR=$(cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep IPADDR)
hostname=$(hostnamectl | grep 'Static hostname')

if [ ! $IPADDR ]; then
  echo "[Error]: IPADDR is none" && exit
fi

echo $hostname
echo $IPADDR
