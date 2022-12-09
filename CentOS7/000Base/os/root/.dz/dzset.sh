#!/bin/bash

# Get param from command input
ipAddrNew=$1
hostNameNew=$2
ifcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33

# Get info before
ipAddrOld=$(cat ${ifcfgPath} | grep IPADDR)
hostNameOld=$(hostnamectl | grep 'Static hostname')

# Default hostname
ipMap["100"]="OOS"
ipMap["128"]="Base"
ipMap["130"]="MySQL"
ipMap["150"]="K8sMaster"
ipMap["151"]="K8sNode1"

# Validate ip
if [[ ! $ipAddrNew =~ ^[0-9]{1,3}$ ]]; then
  echo ""
  echo "[Error]: Param ipAddrNew is invalid"
  echo ""
  exit
fi

# Validate hostname
if [ ! $hostNameNew ] && [ ! ${ipMap[$ipAddrNew]} ]; then
  echo ""
  echo "[Error]: The ip does not have default hostname, please set second param"
  echo ""
  exit
fi

if [ ! $hostNameNew ] && [ ${ipMap[$ipAddrNew]} ]; then
  hostNameNew=$ipAddrNew${ipMap[$ipAddrNew]}
fi

# Backinfo
echo ""
echo "Old Info"
echo "  ipAddr:" $ipAddrOld
echo "hostName:" $hostNameOld
echo ""
echo "New Info"
echo "  ipAddr:" $ipAddrNew
echo "hostName:" $hostNameNew "# defaultHostName:" ${ipMap[$ipAddrNew]}
echo ""

# Start execute command

# Set hostname
hostnamectl set-hostname $hostNameNew

# Set ip
# If ifcfg-ens33 does not have static ip, append IPADDR
# Otherwise change IPADDR
if [[ ! $ipAddrOld ]]; then
  echo "" >>$ifcfgPath
  echo "IPADDR=\"192.168.59.${ipAddrNew}\"" >>$ifcfgPath
  echo "NETMASK=\"255.255.255.0\"" >>$ifcfgPath
  echo "GATEWAY=\"192.168.226.2\"" >>$ifcfgPath
  echo "DNS1=\"8.8.8.8\"" >>$ifcfgPath
else
  sed -i "s/^\(IPADDR=\"192.168.[0-9]*\).[0-9]*/\1.${ipAddrNew}/g" $ifcfgPath
fi

# Restart network
systemctl restart network
echo "Service Network Restart Successfully!"

# Message
echo "Change Successfully!"
echo ""
