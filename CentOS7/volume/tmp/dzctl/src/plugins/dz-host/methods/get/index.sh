#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!" && exit 1
    ;;
  esac
done

StageNo=0

logStage $StageNo "Get network info"
ifcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
StaticIp=$(cat ${ifcfgPath} | grep IPADDR | awk '{ ~ /([0-9]{1,3}\.){3}[0-9]{1,3}/ print $1}')
Gateway=$(cat ${ifcfgPath} | grep GATEWAY | awk '{ ~ /([0-9]{1,3}\.){3}[0-9]{1,3}/ print $1}')
let StageNo+=1

logStage $StageNo "Get host info"
Hostname=$(hostname)
let StageNo+=1

logStage $StageNo "Show"
logFile $ifcfgPath &&
  logValue "Static Ip" $StaticIpNew $StaticIp &&
  logValue "Gateway  " $GatewayNew $Gateway
logFile "hostname" &&
  logValue "Hostname " $HostnameNew $Hostname
