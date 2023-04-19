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
  echo -e "${RED}                [Error] $1 ${RES}"
  echo ""
}

StageRemark=(
  "[Stage00]"
  "[Stage01] Validate     | Validate param"
  "[Stage02] GetNetConfig | Get net config"
  "[Stage03] GetHostname  | Get hostname"
  "[Stage04] IntegerInfo  | Show integer info"
)

# Validate | Validate param
logStage "${StageRemark[1]}"
# [[ $* =~ get ]] && echo Error get && exit

# GetNetConfig | Get net config
logStage "${StageRemark[2]}"
## Get
ifcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
StaticIp=$(cat ${ifcfgPath} | grep IPADDR | awk -F= '{ print $2}' | awk -F\" '{ print $2}')
Gateway=$(cat ${ifcfgPath} | grep GATEWAY | awk -F= '{ print $2}' | awk -F\" '{ print $2}')
logStep "[Get] From ===> $ifcfgPath"
logStep "[Get] Static ip ===> $StaticIp"
logStep "[Get] From ===> $ifcfgPath"
logStep "[Get] Gateway ===> $Gateway"

# GetHostname | Get hostname
logStage "${StageRemark[3]}"
## Get
Hostname=$(hostname)
logStep "[Get] Hostname ===> $Hostname"
logStep "[Get] From ===> hostname"

# IntegerInfo | Show integer info
logStage "${StageRemark[4]}"
logStep "[Get] Static ip ===> $StaticIp"
logStep "[Get] Gateway   ===> $Gateway"
logStep "[Get] Hostname  ===> $Hostname"

# Other
echo ""
echo ""
