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
StaticIp=$(cat ${ifcfgPath} | grep IPADDR | awk '{ ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ print $1}')
Gateway=$(cat ${ifcfgPath} | grep GATEWAY | awk '{ ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ print $1}')
let StageNo+=1

logStage $StageNo "Get host info"
Hostname=$(hostname)
let StageNo+=1

logStage $StageNo "Show"
logStep "[Get] Network info"
logStep "${Space04}From $ifcfgPath"
logStep "${Space04}Static Ip ==> $StaticIp"
logStep "${Space04}Gateway   ==> $Gateway"
logStep "[Get] Host info"
logStep "${Space04}From hostname"
logStep "${Space04}Hostname  ==> $Hostname"
