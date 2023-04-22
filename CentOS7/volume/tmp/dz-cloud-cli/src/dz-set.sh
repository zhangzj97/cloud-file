#!/bin/bash

# Get param from command input
ipAddrSuffixNew=$1
hostNameNew=$2
ifcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33

IPADDR_NEW="192.168.${ipAddrSuffixNew}"
NETMASK=255.255.255.0
GATEWAY=192.168.226.2
DNS1=8.8.8.8

# Get info old
IPADDR_OLD=$(cat ${ifcfgPath} | grep IPADDR)
hostNameOld=$(hostnamectl | grep 'Static hostname')

# Validate ip
if [[ ! $ipAddrSuffixNew =~ ^[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo '[Error]: Param ipAddrSuffixNew is invalid.' && exit
fi

# Validate hostname
if [ ! $hostNameNew ]; then
  echo '[Error]: The ip does not have default hostname, please set second param.' && exit
fi

# Set hostname
hostnamectl set-hostname $hostNameNew

# Set ip
sed -i '/# <Dz> IP/,/# <\/Dz> IP/d' $ifcfgPath
echo '# <Dz> IP' >>/$ifcfgPath
echo "IPADDR=${IPADDR_NEW}" >>$ifcfgPath
echo "NETMASK=${NETMASK}" >>$ifcfgPath
echo "GATEWAY=${GATEWAY}" >>$ifcfgPath
echo "DNS1=${DNS1}" >>$ifcfgPath
echo '# </Dz> IP' >>/$ifcfgPath

# Restart network
systemctl restart network
echo 'Service Network Restart Successfully!'

# Message
echo ''
echo 'Net Info Update Successfully!'
echo '  IPADDR:' $IPADDR_OLD '--->' $IPADDR_NEW
echo 'hostName:' $hostNameOld '--->' $hostNameNew
echo ''
