#!/bin/bash -i

sourceRemote=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/
file=/root/.dz/dzfile.sh

mkdir -p /root/.dz
mkdir -p /etc/docker
mkdir -p /etc/pki/dz

chmod -R 755 /root/.dz
chmod -R 755 /etc/docker
chmod -R 755 /etc/sysctl.d
chmod -R 755 /etc/yum.repos.d
chmod -R 755 /etc/pki/dz

echo ""
echo "   Deleting: " $file
rm -f $file
echo "Downloading: " $file
echo "     Source: " $sourceRemote/$file
echo ""
curl -o $file -fsSL $sourceRemote/$file

chmod -R 755 /root/.dz
/root/.dz/dzfile.sh

/root/.dz/dzalias.sh
