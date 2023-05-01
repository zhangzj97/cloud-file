#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l xxx: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit
    ;;
  esac
done

###################################################################################################
## 业务
###################################################################################################

StageNo=1

dzLogStage $StageNo "获取信息"
dzLogInfo "获取网络信息"
IfcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
dzTmpFsPush $IfcfgPath &&
  StaticIp=$(dzTmpFsMatch $IfcfgPath 's/IPADDR="*([[:alnum:].]*)"*/1/g') &&
  Gateway=$(dzTmpFsMatch $IfcfgPath 's/GATEWAY="*([[:alnum:].]*)"*/1/g') &&
  dzTmpFsPull $IfcfgPath
dzLogInfo "获取主机信息"
Hostname=$(hostname)
let StageNo+=1

dzLogStage $StageNo "信息"
dzLogInfo "StaticIp => ${StaticIp}"
dzLogInfo "Gateway  => ${Gateway}"
dzLogInfo "Hostname => ${Hostname}"
let StageNo+=1
