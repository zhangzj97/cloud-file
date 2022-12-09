#!/bin/bash -i

ipAddrNew=$1
hostNameNew=$2

pathRoot=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/

mkdir -p /root/.dz
chmod -R 755 /root/.dz

fileList=(
  "/root/.dz/.bashrc"
  "/root/.dz/dzfile.sh"
  "/root/.dz/dzcheck.sh"
  "/root/.dz/dzsys.sh"
  "/root/.dz/dzset.sh"
)

for file in ${fileList[@]}; do
  echo ""
  echo "   Deleting: " $file
  rm -f $file
  echo "Downloading: " $file
  echo "     Source: " $file
  echo ""
  curl -o $file -fsSL $pathRoot/$file
done

chmod -R 755 /root/.dz

/root/.dz/dzalias.sh

/root/.dz/dzset.sh $ipAddrNew $hostNameNew
