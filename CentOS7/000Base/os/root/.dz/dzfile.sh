#!/bin/bash

pathRoot=https://raw.githubusercontent.com/zhangzj97/cloud-file/blob/main/CentOS7/000Base/os/

fileList=(
    "/root/.dz/dzalias.sh"
    "/root/.dz/dzcheck.sh"
    "/root/.dz/dzsys.sh"
    "/root/.dz/dzset.sh"
)

for file in ${fileList[@]}; do
    echo ""
    echo "   Deleting: " $file
    rm -f $file
    echo "Downloading: " $file
    echo "     Source: " $pathRoot/$file
    echo ""
    curl -o $file -fsSL $pathRoot/$file
done
