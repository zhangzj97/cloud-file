#!/bin/bash -i

TextRed='\e[1;31m'
TextGreen='\e[1;32m'
TextYellow='\e[1;33m'
TextBlue='\e[1;34m'
TextPink='\e[1;35m'
TextClear='\e[0m'

Space04="    "
Space08=$Space04$Space04
Space12=$Space08$Space04
Space16=$Space08$Space08
Space20=$Space16$Space04
Space24=$Space20$Space08
Space28=$Space24$Space04
Space32=$Space28$Space04

logStage() {
  echo ""
  echo ""
  echo -e "${Space16}${TextBlue}============================================================"
  echo -e "${Space16}${TextBlue}[Stage$1] $2 ${TextClear}"
}

logStep() {
  echo -e "${Space16}$1"
}

logResult() {
  echo -e "${Space32}${TextGreen}[RESULT] Finish Stage Successfully! ${TextClear}"
  echo ""
}

logErrorResult() {
  echo -e "${Space16}${TextRed}[Error] $1 ${RES}"
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

StageNo=1

logStage $StageNo "Register param in /etc/profile.d/dz.sh"
DZ_CLOUD_PATH=/tmp
[[ ! $1 =~ ^\/ ]] && logErrorResult "DZ_CLOUD_PATH is invalid" && exit 0
[[ $1 ]] && DZ_CLOUD_PATH=$1
[[ ! -d $DZ_CLOUD_PATH ]] && mkdir -p $DZ_CLOUD_PATH
[[ ! -f /etc/profile.d/dz.sh ]] && touch /etc/profile.d/dz.sh
sed -i '/# <Dz> Dz/,/# <\/Dz> Dz/d' /etc/profile.d/dz.sh
echo '# <Dz> Dz' >>/etc/profile.d/dz.sh
echo "DZ_CLOUD_PATH=${DZ_CLOUD_PATH}" >>/etc/profile.d/dz.sh
echo "DZ_TOOL_PATH=${DZ_CLOUD_PATH}/cloud-file/CentOS7/volume/tmp/dztool/index.sh" >>/etc/profile.d/dz.sh
echo 'export DZ_CLOUD_PATH DZ_TOOL_PATH' >>/etc/profile.d/dz.sh
echo '# </Dz> Dz' >>/etc/profile.d/dz.sh
source /etc/profile
let StageNo+=1

logStage $StageNo "Add DNS in /etc/hosts"
sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts
let StageNo+=1

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
let StageNo+=1

logStage $StageNo "Install dz-cloud-cli"
# get latest version
DzCloudVersion=$(wget -O- -q https://api.github.com/repos/zhangzj97/cloud-file/releases/latest | jq -r '.tag_name')
DzCloudInstallerPath=$DZ_CLOUD_PATH/cloud-file-${DzCloudVersion}.tar.gz
logStep "Check dz-cloud-cli latest version ==> ${DzCloudInstallerPath}"
if [[ -f $DzCloudInstallerPath && $(tar -tf ${DzCloudInstallerPath}) ]]; then
  logStep "Find dz-cloud-cli installer in ${DzCloudInstallerPath}"
else
  logStep "Download dz-cloud-cli installer"
  wget -t0 -T5 -O $DzCloudInstallerPath https://github.com/zhangzj97/cloud-file/archive/refs/tags/$DzCloudVersion.tar.gz --no-check-certificate
fi
logStep "Register dzadm & dzctl"
tar -xf $DzCloudInstallerPath -C $DZ_CLOUD_PATH/
cpDir $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion $DZ_CLOUD_PATH/cloud-file
rm -fr $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion
lnCli $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzadm/index.sh dzadm
lnCli $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/index.sh dzctl

# Other
echo ""
echo "7"
