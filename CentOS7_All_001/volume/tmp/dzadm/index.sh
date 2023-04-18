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
  echo -e "${GREEN}                [Error] $1 ${RES}"
  echo ""
}

StageRemark=(
  "[Stage00]"
  "[Stage01] AddDNS      | Add DNS host"
  "[Stage02] AddSoftware | Add some software"
  "[Stage03] AddDzCTL    | Add dz-ctl"
)

# AddDNS | Add DNS host
logStage "${StageRemark[1]}"
## [Edit] Github DNS
logStep "Edit: update file /etc/hosts"
sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts

# AddSoftware | Add some software
logStage "${StageRemark[2]}"
# [Install] epel
logStep "Install: check package epel"
[[ ! $(rpm -qa | grep epel-release) ]] && yum install -y -q epel-release
# [Install] wget
logStep "Install: check package wget"
[[ ! $(wget --version) ]] && yum install -y -q wget
# [Install] vim
logStep "Install: check package vim"
[[ ! $(vim --version) ]] && yum install -y -q vim
# [Install] jq
logStep "Install: check package jq"
[[ ! $(jq --version) ]] && yum install -y -q jq
# [Install] git
logStep "Install: check package git"
[[ ! $(git --version) ]] && yum install -y -q git

# AddDzCloud | Add dz-cloud from remote
logStage "${StageRemark[3]}"
DzAdmDirName=/tmp/cloud-file/CentOS7_All_001/volume/tmp/dzadm
DzCtlDirName=/tmp/cloud-file/CentOS7_All_001/volume/tmp/dzctl
# [Install] dz-ctl
logStep "Install: get latest version"
DzCloudVersion=$(wget -O- -q https://api.github.com/repos/zhangzj97/cloud-file/releases/latest | jq -r '.tag_name')
DzCloudDirName=cloud-file-${DzCloudVersion:1}
DzCloudTarName=cloud-file-${DzCloudVersion:1}.tar.gz
logStep "Install: check latest version tar ===> ${DzCloudTarName}"
if [[ -f /tmp/$DzCloudTarName && $(tar -tf /tmp/$DzCloudTarName) ]]; then
  logStep "Install: file exists ===> /tmp/${DzCloudTarName}"
else
  logStep "Install: download dz-cloud"
  wget -t0 -T5 -O /tmp/$DzCloudTarName https://github.com/zhangzj97/cloud-file/archive/refs/tags/$DzCloudVersion.tar.gz --no-check-certificate
fi
logStep "Install: setup dz-cloud"
tar -xvf /tmp/$DzCloudTarName -C /tmp/ >/tmp/null
logStep "Install: add dir /tmp/cloud-file"
rm -fr /tmp/cloud-file
/bin/cp -fa /tmp/${DzCloudDirName} /tmp/cloud-file
rm -fr /tmp/${DzCloudDirName}
# [Edit] dzadm
logStep "Install: add dir /tmp/dzadm"
/bin/cp -fa $DzAdmDirName /tmp/dzadm
logStep "Install: register dzadm"
chmod u+x /tmp/dzadm/index.sh
ln -fs /tmp/dzadm/index.sh /bin/dzadm
# [Edit] dzctl
logStep "Install: add dir /tmp/dzctl"
/bin/cp -fa $DzCtlDirName /tmp/dzctl
logStep "Install: register dzctl"
chmod u+x /tmp/dzctl/index.sh
ln -fs /tmp/dzctl/index.sh /bin/dzctl

# Other
echo ""
echo ""
