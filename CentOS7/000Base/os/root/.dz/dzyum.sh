#!/bin/bash

yum install -y yum-utils
yum-config-manager --add-repo /etc/yum.repo.d/dz-centos.repo
yum-config-manager --add-repo /etc/yum.repo.d/dz-docker.repo
yum-config-manager --add-repo /etc/yum.repo.d/dz-k8s.repo
yum-config-manager --add-repo /etc/yum.repo.d/dz-mysql.repo
yum-config-manager --add-repo /etc/yum.repo.d/dz-nginx.repo

yum install -y wget
yum install -y device-mapper-persistent-data
yum install -y lvm2
yum install -y net-tools
yum install -y vim
yum install -y gcc-c++
yum install -y zlib
yum install -y zlib-devel
yum install -y openssl
yum install -y openssl-devel
yum install -y pcre-devel

yum install -y nginx

yum install -y docker-ce-19.03.*
yum install -y docker-ce-cli
yum install -y containerd.io

yum install -y java-11-openjdk
yum install -y jenkins

yum install -y kubelet-1.18.6
yum install -y kubeadm-1.18.6
yum install -y kubectl-1.18.6

yum install -y mysql-community-server
