#!/bin/bash

pathRoot=https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/root

mkdir /root/.dz
chmod -R 755 /root/.dz

curl -o /root/.dz.bashrc     -fsSL $pathRoot/.dz.bashrc
curl -o /root/.dz/dzinit.sh  -fsSL $pathRoot/.dz/dzinit.sh
curl -o /root/.dz/dzcheck.sh -fsSL $pathRoot/.dz/dzcheck.sh
curl -o /root/.dz/dzsys.sh   -fsSL $pathRoot/.dz/dzsys.sh
curl -o /root/.dz/dzset.sh   -fsSL $pathRoot/.dz/dzset.sh
