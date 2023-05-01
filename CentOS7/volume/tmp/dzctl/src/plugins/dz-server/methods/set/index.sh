#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l ip:,name:,gateway: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --ip)
    StaticIp=$2 && shift 2
    ;;
  --name)
    Hostname=$2 && shift 2
    ;;
  --gateway)
    Gateway=$2 && shift 2
    ;;
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit
    ;;
  esac
done
[[ $StaticIp && ! $StaticIp =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && dzLogError "option --domain is invalid" && exit
# [[ ! $Hostname ]] && dzLogError "option --port is invalid" && exit 0
[[ $Gateway && ! $Gateway =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && dzLogError "option --port is invalid" && exit

StageNo=0

dzLogStage $StageNo "修改网络信息"
IfcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
NetworkRestartFlag=
if [[ $StaticIp ]]; then
  dzTmpFsPush $IfcfgPath &&
    StaticIpPrev=$(dzTmpFsMatch $IfcfgPath 's|^.*IPADDR="?([^"]*)"?.*$|\1|g') &&
    dzTmpFsEdit $IfcfgPath "/IPADDR=.*/d" &&
    dzTmpFsEdit $IfcfgPath "\$a IPADDR=${StaticIp}" &&
    dzTmpFsPull $IfcfgPath
  dzLogInfo "StaticIp : $StaticIpPrev => $StaticIp"
  NetworkRestartFlag=1
fi
if [[ $Gateway ]]; then
  dzTmpFsPush $IfcfgPath &&
    GatewayPrev=$(dzTmpFsMatch $IfcfgPath 's|^.*GATEWAY="?([^"]*)"?.*$|\1|g') &&
    dzTmpFsEdit $IfcfgPath "/GATEWAY=.*/d" &&
    dzTmpFsEdit $IfcfgPath "\$a GATEWAY=${Gateway}" &&
    dzTmpFsPull $IfcfgPath
  dzLogInfo "Gateway : $GatewayPrev => $Gateway"
  NetworkRestartFlag=1
fi
[[ $NetworkRestartFlag ]] && systemctl restart network
let StageNo+=1

dzLogStage $StageNo "修改主机信息"
if [[ $Hostname ]]; then
  HostnamePrev=$(hostname) &&
    hostnamectl set-hostname $Hostname
  dzLogInfo "Hostname : $HostnamePrev => $Hostname"
fi
let StageNo+=1
