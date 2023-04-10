#!/bin/bash

# Get param from command input
ipAddrNew=$1
hostNameNew=$2
ifcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33

# Get info before
ipAddrOld=$(cat ${ifcfgPath} | grep IPADDR)
hostNameOld=$(hostnamectl | grep 'Static hostname')

# Validate ip
if [[ ! $ipAddrNew =~ ^[0-9]{1,3}$ ]]; then
  echo "\n[Error]: Param ipAddrNew is invalid\n"
  exit
fi

# Validate hostname
if [ ! $hostNameNew ]; then
  echo "\n[Error]: The ip does not have default hostname, please set second param.\n"
  exit
fi

# Set hostname
hostnamectl set-hostname $hostNameNew

# Set ip
# If ifcfg-ens33 does not have static ip, append IPADDR
# Otherwise change IPADDR
sed -i "s/^# Start Static IP(*)# End Static IP/""/g" $ifcfgPath
echo "# Start Static IP" >>$ifcfgPath
echo "IPADDR=\"192.168.226.${ipAddrNew}\"" >>$ifcfgPath
echo "NETMASK=\"255.255.255.0\"" >>$ifcfgPath
echo "GATEWAY=\"192.168.226.2\"" >>$ifcfgPath
echo "DNS1=\"8.8.8.8\"" >>$ifcfgPath
echo "# End Static IP" >>$ifcfgPath

# Restart network
systemctl restart network
echo "Service Network Restart Successfully!"

# Message
echo ""
echo "Info Update Successfully"
echo "  ipAddr:" $ipAddrOld "--->" $ipAddrNew
echo "hostName:" $hostNameOld "--->" $hostNameNew
echo ""
