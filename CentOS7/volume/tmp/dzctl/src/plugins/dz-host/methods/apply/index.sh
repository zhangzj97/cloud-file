#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l ip:,name:,gateway: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --ip)
    StaticIpNew=$2 && shift 2
    ;;
  --name)
    HostnameNew=$2 && shift 2
    ;;
  --gateway)
    GatewayNew=$2 && shift 2
    ;;
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!" && exit 1
    ;;
  esac
done
[[ $StaticIpNew && ! $StaticIpNew =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && logErrorResult "option --domain is invalid" && exit 0
# [[ ! $HostnameNew ]] && logErrorResult "option --port is invalid" && exit 0
[[ $GatewayNew && ! $GatewayNew =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && logErrorResult "option --port is invalid" && exit 0

StageNo=0

logStage $StageNo "Get network info"
ifcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
StaticIp=$(cat ${ifcfgPath} | grep IPADDR | awk '{ ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ print $1}')
Gateway=$(cat ${ifcfgPath} | grep GATEWAY | awk '{ ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ print $1}')
let StageNo+=1

logStage $StageNo "Get host info"
Hostname=$(hostname)
let StageNo+=1

logStage $StageNo "Set info and restart service"
NetworkRestartFlag=false
if [[ $StaticIpNew ]]; then
  logFile $ifcfgPath && logValue "Static Ip" $StaticIpNew $StaticIp
  sed -i 's/IPADDR=.*//' $ifcfgPath && dzTextAppend $ifcfgPath "IPADDR=${StaticIpNew}"
  NetworkRestartFlag=true
fi
if [[ $GatewayNew ]]; then
  logFile $ifcfgPath && logValue "Gateway  " $GatewayNew $Gateway
  sed -i 's/GATEWAY=.*//' $ifcfgPath && dzTextAppend $ifcfgPath "GATEWAY=${GatewayNew}"
  NetworkRestartFlag=true
fi
if [[ $HostnameNew ]]; then
  logFile "hostname" && logValue "Hostname " $HostnameNew $Hostname
  hostnamectl set-hostname $HostnameNew
fi
[[ $NetworkRestartFlag = true ]] && systemctl restart network
