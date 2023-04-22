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
  echo -e "${BLUE}                [Stage$2] $1 ${RES}"
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

cpDir() {
  rm -fr $2
  mkdir -p $2
  /bin/cp -fa $1/* $2
}

lnCli() {
  chmod u+x $1
  ln -fs $1 /bin/$2
}

StageRemark=(
  "[Stage00]"
  "[Stage01] AddDNS      | Add DNS host"
  "[Stage02] AddSoftware | Add some software"
  "[Stage03] AddDzCTL    | Add dz-ctl"
)

StageNo=1

logStage $StageNo "Add DNS in /etc/hosts"
sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts
StageNo = $StageNo + 1

logStage $StageNo "Install some softwares"
logStep "Checking package epel"
[[ ! $(rpm -qa | grep epel-release) ]] && yum install -y -q epel-release
logStep "Checking package wget"
[[ ! $(wget --version) ]] && yum install -y -q wget
logStep "Checking package vim"
[[ ! $(vim --version) ]] && yum install -y -q vim
logStep "Checking package jq"
[[ ! $(jq --version) ]] && yum install -y -q jq
logStep "Checking package git"
[[ ! $(git --version) ]] && yum install -y -q git
StageNo = $StageNo + 1

logStage $StageNo "Install dz-cloud-cli"
DzadmDirPath=/tmp/cloud-file/CentOS7/volume/tmp/dzadm
DzctlDirPath=/tmp/cloud-file/CentOS7/volume/tmp/dzctl
# get latest version
DzCloudVersion=$(wget -O- -q https://api.github.com/repos/zhangzj97/cloud-file/releases/latest | jq -r '.tag_name')
DzCloudInstallerPath=/tmp/cloud-file-${DzCloudVersion}.tar.gz
logStep "Check dz-cloud-cli latest version ==> ${DzCloudTarName}"
if [[ -f $DzCloudInstallerPath && $(tar -tf ${DzCloudInstallerPath}) ]]; then
  logStep "Download dz-cloud-cli installer"
  wget -t0 -T5 -O $DzCloudInstallerPath https://github.com/zhangzj97/cloud-file/archive/refs/tags/$DzCloudVersion.tar.gz --no-check-certificate
fi
logStep "Register dzadm and dzctl"
tar -xvf $DzCloudInstallerPath -C /tmp/ >/tmp/null
cpDir /tmp/cloud-file-${DzCloudVersion} /tmp/cloud-file
rm -fr /tmp/cloud-file-${DzCloudVersion}
lnCli $DzadmDirPath/index.sh dzadm
lnCli $DzctlDirPath/index.sh dzctl

# Other
echo ""
echo "7"
