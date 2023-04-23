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
  echo -e "${Space16}${TextBlue}[Stage$1] $2${TextClear}"
}

logStep() {
  echo -e "${Space16}$1"
}

# logValue CurrentValue PrevValue Label
logValue() {
  echo -e "${Space16}[$3] Form $2"
  echo -e "${Space16}[$3] To   ${TextBlue}$1${TextClear}"
}

# logFile file
logFile() {
  echo -e "${Space16}${TextBlue}[Changed] $1"
}

# logDir dir
logFile() {
  echo -e "${Space16}${TextBlue}[Changed] $1"
}

logErrorResult() {
  echo -e "${Space16}${TextRed}[Error] $1${TextClear}"
  echo ""
}

# dzYum source target
cpDir() {
  rm -fr $2
  mkdir -p $2
  /bin/cp -fa $1/* $2
}

# dzYum file bin
lnSh() {
  chmod u+x $1
  ln -fs $1 /bin/$2
}

# dzYum rpm
dzYum() {
  if [[ ! $(rpm -qa | grep $1) ]]; then
    yum install -y -q $1
  fi
}

# dzTarc file label
dzTextRemove() {
  sed -i "/# <Dz> $2/,/# <\/Dz> $2/d" $1
}

# dzTarc file text
dzTextAppend() {
  echo $2 >>$1
}

# dzTarc file dir
dzTarc() {
  tar -czv $1 $2
}

# dzTarc file dir
dzTarx() {
  mkdir -p $2
  tar -xzv $1 -C $2
}

# dzTarc file url
dzWget() {
  wget -t0 -T5 -O $1 $2 --no-check-certificate
}

StageNo=1

logStage $StageNo "Register param in /etc/profile.d/dz.sh"
[[ ! $1 =~ ^\/ ]] && logErrorResult "DZ_CLOUD_PATH is invalid" && exit 0
DZ_CLOUD_PATH=${1:-"/tmp"}
logDir $DZ_CLOUD_PATH && mkdir -p $DZ_CLOUD_PATH
logFile /etc/profile.d/dz.sh && touch /etc/profile.d/dz.sh
dzTextRemove /etc/profile.d/dz.sh "DzSh"
dzTextAppend /etc/profile.d/dz.sh "# <Dz> DzSh"
dzTextAppend /etc/profile.d/dz.sh "DZ_CLOUD_PATH=${DZ_CLOUD_PATH}"
dzTextAppend /etc/profile.d/dz.sh "DZ_TOOL_PATH=${DZ_CLOUD_PATH}/cloud-file/CentOS7/volume/tmp/dztool/index.sh"
dzTextAppend /etc/profile.d/dz.sh "export DZ_CLOUD_PATH DZ_TOOL_PATH"
dzTextAppend /etc/profile.d/dz.sh "# </Dz> DzSh"
source /etc/profile
let StageNo+=1

logStage $StageNo "Add DNS in /etc/hosts"
logFile /etc/hosts && touch /etc/hosts
dzTextRemove /etc/hosts "GitHub"
dzTextAppend /etc/hosts "# <Dz> GitHub"
dzTextAppend /etc/hosts "185.199.110.133 raw.githubusercontent.com"
dzTextAppend /etc/hosts "140.82.113.3    raw.github.com"
dzTextAppend /etc/hosts "140.82.112.4    raw.github.com"
dzTextAppend /etc/hosts "# </Dz> GitHub"
let StageNo+=1

logStage $StageNo "Install some softwares"
logStep "Checking Package epel-release" && dzYum epel-release
logStep "Checking Package yum-utils   " && dzYum yum-utils
logStep "Checking Package wget        " && dzYum wget
logStep "Checking Package vim         " && dzYum vim
logStep "Checking Package jq          " && dzYum jq
logStep "Checking Package git         " && dzYum git
let StageNo+=1

logStage $StageNo "Install dz-cloud-cli"
DzCloudVersion=$(wget -O- -q https://api.github.com/repos/zhangzj97/cloud-file/releases/latest | jq -r '.tag_name')
DzCloudInstallerPath=$DZ_CLOUD_PATH/cloud-file-${DzCloudVersion}.tar.gz
logStep "Checking dz-cloud-cli latest version ==> ${DzCloudInstallerPath}"
if [[ ! -f $DzCloudInstallerPath || ! $(tar -tf ${DzCloudInstallerPath}) ]]; then
  logStep "Download dz-cloud-cli installer"
  logFile $DzCloudInstallerPath
  dzWget $DzCloudInstallerPath https://github.com/zhangzj97/cloud-file/archive/refs/tags/$DzCloudVersion.tar.gz
fi
logStep "Register dzadm & dzctl"
logDir $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion
logDir $DZ_CLOUD_PATH/cloud-file
dzTarx $DzCloudInstallerPath $DZ_CLOUD_PATH
cpDir $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion $DZ_CLOUD_PATH/cloud-file
rm -fr $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion
lnSh $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzadm/index.sh dzadm
lnSh $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/index.sh dzctl
