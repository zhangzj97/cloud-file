#!/bin/bash

# Close SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
echo "Close SELinux Successfully!"

# Close firewall
systemctl stop firewalld
systemctl disable firewalld
echo "Close firewall Successfully!"

# Close swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo "Close swap Successfully!"

# Restart Service
sysctl --system
systemctl daemon-reload
