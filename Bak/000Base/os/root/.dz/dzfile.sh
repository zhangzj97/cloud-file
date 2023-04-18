#!/bin/bash

sourceRemote=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/

fileList=(
    "/root/.dz/dzalias.sh"
    "/root/.dz/dzcheck.sh"
    "/root/.dz/dzfirewall.sh"
    "/root/.dz/dzhost.sh"
    "/root/.dz/dzreinit.sh"
    "/root/.dz/dzssl.sh"
    "/root/.dz/dzsys.sh"
    "/root/.dz/dzset.sh"
    "/root/.dz/dzyum.sh"

    "/etc/yum.repos.d/dz-centos.repo"
    "/etc/yum.repos.d/dz-docker.repo"
    "/etc/yum.repos.d/dz-gitlab.repo"
    "/etc/yum.repos.d/dz-jenkins.repo"
    "/etc/yum.repos.d/dz-k8s.repo"
    "/etc/yum.repos.d/dz-mysql.repo"
    "/etc/yum.repos.d/dz-nginx.repo"

    "/etc/systemd/system/cri-docker.service"
    "/etc/systemd/system/cri-docker.socket"

    "/etc/docker/daemon.json"

    "/etc/sysctl.d/kubernetes.conf"

    "/etc/pki/rpm-gpg/jenkins.io.key"

)

for file in ${fileList[@]}; do
    rm -f $file
    echo "Source: " $sourceRemote/$file
    curl -o $file -fsSL $sourceRemote/$file
done

chmod -R 755 /root/.dz
