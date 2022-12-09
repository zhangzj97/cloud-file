#!/bin/bash -i

sourceRemote=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/
file=/root/.dz/dzfile.sh

mkdir -p /root/.dz
mkdir -p /etc/docker

chmod -R 755 /root/.dz
chmod -R 755 /etc/docker
chmod -R 755 /etc/sysctl.d
chmod -R 755 /etc/yum.repo.d

echo ""
echo "   Deleting: " $file
rm -f $file
echo "Downloading: " $file
echo "     Source: " $sourceRemote/$file
echo ""
curl -o $file -fsSL $sourceRemote/$file

/root/.dz/dzfile.sh

/root/.dz/dzalias.sh
