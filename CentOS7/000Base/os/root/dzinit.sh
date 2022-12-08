#!/bin/bash

ipAddrNew=$1
hostNameNew=$2

pathRoot=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/

mkdir -p /root/.dz
chmod -R 755 /root/.dz

fileList=(
  "/root/.dz.bashrc"
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
  echo "     source: " $file
  echo ""
  curl -o $file -fsSL $pathRoot/$file
done

chmod -R 755 /root/.dz

alias dzcheck="/root/.dz/dzcheck.sh"
alias dzset="/root/.dz/dzset.sh"
alias dzsys="/root/.dz/dzsys.sh"
alias dzinit="/root/.dz/dzinit.sh"

echo "1"

dzset $ipAddrNew $hostNameNew
echo "2"

/root/.dz/dzset.sh $ipAddrNew $hostNameNew
