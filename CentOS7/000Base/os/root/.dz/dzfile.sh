#!/bin/bash

sourceRemote=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/

fileList=(
    "/root/.dz/dzalias.sh"
    "/root/.dz/dzcheck.sh"
    "/root/.dz/dzsys.sh"
    "/root/.dz/dzset.sh"
    "/root/.dz/dzyum.sh"

    "/etc/yum.repo.d/dz-docker.repo"
    "/etc/yum.repo.d/dz-k8s.repo"
    "/etc/yum.repo.d/dz-mysql.repo"
    "/etc/yum.repo.d/dz-nginx.repo"

    "/etc/docker/daemon.json"

    "/etc/sysctl.d/kubernetes.conf"

)

for file in ${fileList[@]}; do
    echo ""
    echo "   Deleting: " $file
    rm -f $file
    echo "Downloading: " $file
    echo "     Source: " $sourceRemote/$file
    echo ""
    curl -o $file -fsSL $sourceRemote/$file
done

chmod -R 755 /root/.dz
