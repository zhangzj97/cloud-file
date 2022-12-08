#!/bin/bash

remoteUrl=https://raw.githubusercontent.com/zhangzj97/cloud-file/blob/main/CentOS7/000Base/os/root
osName=CentOS7

pathRoot=$remoteUrl/$onName/000Base/os/root

curl -o /root/.dz.bashrc     -fsSL $pathRoot/.dz.bashrc
curl -o /root/.dz/dzinit.sh  -fsSL $pathRoot/.dz/dzinit.sh
curl -o /root/.dz/dzcheck.sh -fsSL $pathRoot/.dz/dzcheck.sh
curl -o /root/.dz/dzsys.sh   -fsSL $pathRoot/.dz/dzsys.sh
curl -o /root/.dz/dzset.sh   -fsSL $pathRoot/.dz/dzset.sh
