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

# logValue Label CurrentValue PrevValue
logValue() {
  echo -e "${Space16}[$1] $3 => ${TextBlue}$2${TextClear}"
}

dzLogError() {
  echo -e "${Space16}${TextRed}[ERROR] $1${TextClear}"
  echo ""
}

dzLogInfo() {
  echo -e "${Space16}[INFO] $1"
  echo ""
}

dzLogFs() {
  FsPath=$1
  FsMethodCode=$2
  FsMethodLabel=""

  FsExist=0

  [[ -f $1 ]] && FsExist=1
  [[ -d $1 ]] && FsExist=1

  [[ ! $FsExist && ! $FsMethodCode ]] && FsMethodLabel="未发现 -> 涉及"
  [[ ! $FsExist && $FsMethodCode = "Relate" ]] && FsMethodLabel="未发现 -> 涉及"
  [[ ! $FsExist && $FsMethodCode = "Handle" ]] && FsMethodLabel="未发现 -> 添加"
  [[ ! $FsExist && $FsMethodCode = "Remove" ]] && FsMethodLabel="未发现 -> 删除"

  [[ $FsExist && ! $FsMethodCode ]] && FsMethodLabel="已发现 -> 涉及"
  [[ $FsExist && $FsMethodCode = "Relate" ]] && FsMethodLabel="已发现 -> 涉及"
  [[ $FsExist && $FsMethodCode = "Handle" ]] && FsMethodLabel="已发现 -> 备份 -> 修改"
  [[ $FsExist && $FsMethodCode = "Remove" ]] && FsMethodLabel="已发现 -> 备份 -> 删除"

  echo -e "${Space16}[FS] [${FsMethodLabel}] $FsPath"
  echo ""
}

# cpDir source target
cpDir() {
  rm -fr $2
  mkdir -p $2
  /bin/cp -fa $1/* $2
}

# # 从 volume 中复制 文件或者文件夹 并为原来的文件创建备份
# # cpVol /etc/xxx
# dzPullVol() {
#   FsPath=$1
#   [[ !$FsPath ]] && echo "${TextRed}[ERROR] 需要参数${TextClear}" && exit 0
#   if [[ -d $FsPath ]]; then
#     TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")
#     mv $FsPath $FsPath-$TimeFlag.del.bak
#     /bin/cp -fa --parents $DZ_CLOUD_VOLUME$FilePath/* /
#   fi
#   if [[ -f FilePath ]]; then
#     TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")
#     mv $FilePath $FilePath-$TimeFlag.del.bak
#     /bin/cp -fa --parents $DZ_CLOUD_VOLUME$FilePath /
#   fi
# }

# # 新建一个文件 并自动创建文件夹
# # dzFile /etc/xxx
# dzFile() {
#   FsPath=$1
#   Dir=${FsPath%/*}
#   FileName=${FsPath##*/}

#   [[ ! $FsPath ]] && logErrorResult "参数错误: 缺少参数"
#   [[ ! $FsPath =~ ^/ ]] && logErrorResult "参数错误: 参数必须是绝对路径, 即参数需要 / 开头"
#   [[ ! $FileName ]] && logErrorResult "参数错误: 缺少文件名"
#   [[ $FsPath && ! $Dir ]] && logErrorResult "参数错误: / 下不建议生成文件"

#   if [[ -d $Dir ]]; then
#     echo "$Dir 存在"
#   else
#     mkdir -p $Dir
#     echo "$Dir 不存在 ==> 新建文件夹"
#   fi

#   if [[ -f $FsPath ]]; then
#     TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")
#     mv $FsPath $FsPath-$TimeFlag.dzdelflag.bak
#     touch $FsPath
#     echo "$Dir 不存在 ==> 备份 ==> 新建空文件"
#   else
#     touch $FsPath
#     echo "$Dir 不存在 ==> 新建空文件"
#   fi
# }

# registeBin $CliName $Source
registeBin() {
  $CliName=$1
  $Source=$2

  [[ ! -f $Source ]] && dzLogError "${Source} is not found" && exit 0

  chmod u+x $Source
  ln -fs $Source /bin/$CliName
}

# dzRpmYum $RpmName $CheckName
dzRpmYum() {
  RpmName=$1
  CheckName=$2

  [[ ! $CheckName ]] && CheckName=$RpmName

  [[ ! $(rpm -qa | grep $CheckName) ]] &&
    yum install -y -q $RpmName
}

# dzTarc file dir
dzTarc() {
  tar -czf $1 $2
}

# dzTarc file dir
dzTarx() {
  mkdir -p $2
  tar -xzf $1 -C $2
}

# dzTarc file url
dzWget() {
  wget -t0 -T5 -O $1 $2 --no-check-certificate
}

# 在临时空间生成内容 默认删除已经存在的内容
# dzTmpFsPush $FilePath $Content | $SourceFilePath
dzTmpFsPush() {
  FilePath=$1
  Content=$2

  [[ -f $Content ]] && Content=$(cat ${Content})

  Dir=${FilePath%/*}
  FileName=${FilePath##*/}
  DzTmpFs=${DZ_TMPFS_PATH}
  DzTmpFsFilePath=$DzTmpFs$FileFullPath
  DzTmpFsDir=${DzTmpFsFilePath%/*}
  DzTmpFsFileName=${DzTmpFsFilePath##*/}

  mkdir -p $Dir
  mkdir -p $DzTmpFsDir

  [[ -f $DzTmpFsFilePath ]] && rm -rf $DzTmpFsFilePath

  dzLogFs $DzTmpFsFilePath "Relate" &&
    dzFsCreate $DzTmpFsFilePath &&
    dzFsEdit $DzTmpFsFilePath "s/$/${Content}/g"
}

# 从临时空间获取内容 支持别名 默认备份原本存在的文件
# dzTmpFsPull $FilePath [$FileAliasPath]
dzTmpFsPull() {
  FilePath=$1
  FileAliasPath=$2

  Dir=${FilePath%/*}
  FileName=${FilePath##*/}
  DzTmpFs=${DZ_TMPFS_PATH}
  DzTmpFsFilePath=$DzTmpFs$FileFullPath
  DzTmpFsDir=${DzTmpFsFilePath%/*}
  DzTmpFsFileName=${DzTmpFsFilePath##*/}

  mkdir -p $Dir
  mkdir -p $DzTmpFsDir

  [[ ! -f $DzTmpFsFilePath ]] && dzLogError "${DzTmpFsFilePath} is not found" && exit 0

  if [[ $FileAliasPath ]]; then
    dzLogFs $FileAliasPath "Handle" &&
      dzFsRm $FileAliasPath &&
      dzFsGet $FileAliasPath $DzTmpFsFilePath
  else
    dzLogFs $FilePath "Handle" &&
      dzFsRm $FilePath &&
      dzFsGet $FilePath $DzTmpFsFilePath
  fi
}

# 修改临时空间文件的内容
# dzTmpFsEdit $FilePath $Sed
dzTmpFsEdit() {
  FilePath=$1
  Sed=$2

  Dir=${FilePath%/*}
  FileName=${FilePath##*/}
  DzTmpFs=${DZ_TMPFS_PATH}
  DzTmpFsFilePath=$DzTmpFs$FileFullPath
  DzTmpFsDir=${DzTmpFsFilePath%/*}
  DzTmpFsFileName=${DzTmpFsFilePath##*/}

  [[ ! -f $DzTmpFsFilePath ]] && dzLogError "${DzTmpFsFilePath} is not found" && exit 0

  sed -i $Sed $DzTmpFsFilePath
}

# 清除临时空间
dzTmpFsClear() {
  rm -rf $DzTmpFs/*
}

# 在系统内容中 临时备份文件
# dzFsEdit $FileFullPath
dzFsBackup() {
  FilePath=$1

  TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")

  [[ ! -f $FilePath ]] && dzLogError "${FilePath} is not found"

  /bin/cp -fa $FilePath $FilePath-$TimeFlag.dzdel.bak
}

# 在系统内容中 备份并删除文件
dzFsRm() {
  FilePath=$1

  TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")

  [[ ! -f $FilePath ]] && dzLogError "${FilePath} is not found"

  mv $FilePath $FilePath-$TimeFlag.dzdel.bak
}

# 在系统内容中 清理备份文件
dzFsRmBackup() {}

StageNo=1

DZ_CLOUD_PATH=$1

[[ ! $DZ_CLOUD_PATH =~ ^\/ ]] && logError "DZ_CLOUD_PATH is invalid" && exit 0

logStage $StageNo "全局注册参数 in /etc/profile.d/dz.sh"
mkdir -p $DZ_CLOUD_PATH && logDir $DZ_CLOUD_PATH
touch /etc/profile.d/dz.sh && logFile /etc/profile.d/dz.sh
dzTextRemove /etc/profile.d/dz.sh "DzSh" &&
  dzTextAppend /etc/profile.d/dz.sh "# <Dz> DzSh" &&
  dzTextAppend /etc/profile.d/dz.sh "DZ_CLOUD_PATH=${DZ_CLOUD_PATH}" &&
  dzTextAppend /etc/profile.d/dz.sh "DZ_CLOUD_VOLUME=${DZ_CLOUD_PATH}/cloud-file/CentOS7/volume/" &&
  dzTextAppend /etc/profile.d/dz.sh "DZ_TOOL_PATH=${DZ_CLOUD_VOLUME}/tmp/dztool/index.sh" &&
  dzTextAppend /etc/profile.d/dz.sh "export DZ_CLOUD_PATH DZ_CLOUD_VOLUME DZ_TOOL_PATH" &&
  dzTextAppend /etc/profile.d/dz.sh "# </Dz> DzSh"
source /etc/profile
let StageNo+=1

logStage $StageNo "Add DNS in /etc/hosts"
touch /etc/hosts && logFile /etc/hosts
dzTextRemove /etc/hosts "GitHub" &&
  dzTextAppend /etc/hosts "# <Dz> GitHub" &&
  dzTextAppend /etc/hosts "185.199.110.133 raw.githubusercontent.com" &&
  dzTextAppend /etc/hosts "140.82.113.3    raw.github.com" &&
  dzTextAppend /etc/hosts "140.82.112.4    raw.github.com" &&
  dzTextAppend /etc/hosts "# </Dz> GitHub"
let StageNo+=1

logStage $StageNo "Install wget & epel-release & jq"
logStep "Checking Package wget        " && dzYum wget
logStep "Checking Package epel-release" && dzYum epel-release
logStep "Checking Package jq          " && dzYum jq
let StageNo+=1

logStage $StageNo "Install dz-cloud-cli"
DzCloudVersion=$(wget -O- -q https://api.github.com/repos/zhangzj97/cloud-file/releases/latest | jq -r '.tag_name')
DzCloudInstallerPath=$DZ_CLOUD_PATH/cloud-file-${DzCloudVersion}.tar.gz
logStep "Checking dz-cloud-cli latest version ==> ${DzCloudInstallerPath}"
if [[ ! -f $DzCloudInstallerPath || ! $(tar -tf ${DzCloudInstallerPath}) ]]; then
  logStep "Download dz-cloud-cli installer"
  dzWget $DzCloudInstallerPath https://github.com/zhangzj97/cloud-file/archive/refs/tags/$DzCloudVersion.tar.gz && logFile $DzCloudInstallerPath
fi
logStep "Register dzadm & dzctl"
dzTarx $DzCloudInstallerPath $DZ_CLOUD_PATH &&
  cpDir $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion $DZ_CLOUD_PATH/cloud-file &&
  rm -fr $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion &&
  logDir $DZ_CLOUD_PATH/cloud-file-$DzCloudVersion &&
  logDir $DZ_CLOUD_PATH/cloud-file &&
  logDir $DZ_CLOUD_PATH
lnSh $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzadm/index.sh dzadm
lnSh $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/index.sh dzctl
let StageNo+=1

logStage $StageNo "Install some software"
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/yum.repos.d/* /etc/yum.repos.d/ && logDir /etc/yum.repos.d/
logStep "Checking Package yum-utils   " && dzYum yum-utils
logStep "Checking Package vim         " && dzYum vim "vim-common"
logStep "Checking Package git         " && dzYum git
let StageNo+=1
