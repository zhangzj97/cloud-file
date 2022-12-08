#!/bin/bash

pathRoot=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/

mkdir -p /root/.dz
chmod -R 755 /root/.dz

fileList=(
  "/root/.dz.bashrc",
  "/root/.dz/dzinit.sh",
  "/root/.dz/dzcheck.sh",
  "/root/.dz/dzsys.sh",
  "/root/.dz/dzset.sh",
)

for file in ${fileList[@]}; do
  rm $file
  curl -o $file -fsSL $pathRoot$file
done
