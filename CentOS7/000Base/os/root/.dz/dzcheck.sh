#!/bin/bash

IPADDR=$(cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep IPADDR)
hostname=$(hostnamectl | grep 'Static hostname')

if [ ! $IPADDR ]; then
  echo ""
  echo "[Error]: IPADDR is none"
  echo ""
  exit
fi

echo ""
echo $hostname
echo ""
echo $IPADDR
echo ""
