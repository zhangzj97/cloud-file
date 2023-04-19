#!/bin/bash -i

RED='\e[1;31m'    # 红
GREEN='\e[1;32m'  # 绿
YELLOW='\e[1;33m' # 黄
BLUE='\e[1;34m'   # 蓝
PINK='\e[1;35m'   # 粉红
RES='\e[0m'       # 清除颜色

logStage() {
  echo ""
  echo ""
  echo -e "${BLUE}                ============================================================"
  echo -e "${BLUE}                $1 ${RES}"
}

logStep() {
  echo -e "                    $1"
}

logResult() {
  echo -e "${GREEN}                                [RESULT] Finish Stage Successfully! ${RES}"
  echo ""
}

logErrorResult() {
  echo -e "${RED}                    [Error] $1 ${RES}"
  echo ""
}

StageRemark=(
  "[Stage00]"
  "[Stage01] Validate     | Validate param"
  "[Stage02] SetNetConfig | Set net config"
  "[Stage03] SetHostname  | Set hostname"
)

# Validate | Validate param
logStage "${StageRemark[1]}"
# [[ $* =~ get ]] && echo Error get && exit
ARGS=$(getopt -l ip:,name:,gateway: -n 'dzctl.host' -- "$@")
[ $? != 0 ] && echo Erro && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --ip)
    StaticIpNew=$2
    if [[ ! $StaticIpNew =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      logErrorResult "--ip ===> ${StaticIpNew}"
      exit
    else
      logStep "[Validate] --ip ===> ${StaticIpNew}"
    fi

    shift 2
    ;;
  --name)
    HostnameNew=$2

    if [[ $HostnameNew =~ ^[-] ]]; then
      logErrorResult "--hostname ===> ${HostnameNew}"
      exit
    else
      logStep "[Validate] --hostname ===> ${HostnameNew}"
    fi
    shift 2
    ;;

  --gateway)
    GatewayNew=$2

    if [[ ! $GatewayNew =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      logErrorResult "--gateway ===> ${GatewayNew}"
      exit
    else
      logStep "[Validate] --gateway ===> ${GatewayNew}"
    fi
    shift 2
    ;;
  --)
    break
    ;;

  *)
    logErrorResult "Internal error!"
    exit 1
    ;;

  esac
done

# SetNetConfig | Set net config
logStage "${StageRemark[2]}"
## Get
ifcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
StaticIp=$(cat ${ifcfgPath} | grep IPADDR | awk -F= '{ print $2}' | awk -F\" '{ print $2}')
Gateway=$(cat ${ifcfgPath} | grep GATEWAY | awk -F= '{ print $2}' | awk -F\" '{ print $2}')
logStep "[Get] From ===> $ifcfgPath"
logStep "[Get] Static ip ===> $StaticIp"
logStep "[Get] From ===> $ifcfgPath"
logStep "[Get] Gateway ===> $Gateway"
## Set
SetNetConfigFlag=false
if [[ $StaticIpNew ]]; then
  sed -i 's/IPADDR=.*//' $ifcfgPath
  echo "IPADDR=\"${StaticIpNew}\"" >>$ifcfgPath
  logStep "[Config] Static ip"
  logStep "[Config] $StaticIp ===> $StaticIpNew"
  logStep "[Config] Update ===> $ifcfgPath"
  SetNetConfigFlag=true
fi
if [[ $GatewayNew ]]; then
  sed -i 's/GATEWAY=.*//' $ifcfgPath
  echo "GATEWAY=\"${GatewayNew}\"" >>$ifcfgPath
  logStep "[Config] Gateway"
  logStep "[Config] $Gateway ===> $GatewayNew"
  logStep "[Config] Update ===> $ifcfgPath"
  SetNetConfigFlag=true
fi
[[ $SetNetConfigFlag = true ]] && systemctl restart network

# SetHostname | Set hostname
logStage "${StageRemark[3]}"
## Get
Hostname=$(hostname)
logStep "[Get] Hostname ===> $Hostname"
logStep "[Get] From ===> hostname"
## Set
if [[ $HostnameNew ]]; then
  hostnamectl set-hostname $HostnameNew
  logStep "[Config] Hostname"
  logStep "[Config] $Hostname ===> $HostnameNew"
  logStep "[Config] Update ===> hostnamectl set-hostname $HostnameNew"
fi

# Other
echo ""
echo ""
