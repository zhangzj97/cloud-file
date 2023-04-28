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

dzLogInfo() {
  echo -e "${Space16}[INFO ] $1"
}

dzLogError() {
  echo -e "${Space16}${TextRed}[ERROR] $1${TextClear}"
}

# 日志
# dzLogFs $FsPath $FileMethodCode
dzLogFs() {
  FilePath=$1
  FileMethodCode=$2
  FileMethodLabel=""

  FileExist=

  [[ -f $FilePath ]] && FileExist=1
  [[ -d $FilePath ]] && FileExist=1

  [[ ! $FileExist && ! $FileMethodCode ]] && FileMethodLabel="未发现 -> 涉及"
  [[ ! $FileExist && $FileMethodCode = "Relate" ]] && FileMethodLabel="未发现 -> 涉及"
  [[ ! $FileExist && $FileMethodCode = "Handle" ]] && FileMethodLabel="未发现 -> 添加"
  [[ ! $FileExist && $FileMethodCode = "Remove" ]] && FileMethodLabel="未发现 -> 删除"

  [[ $FileExist && ! $FileMethodCode ]] && FileMethodLabel="已发现 -> 涉及"
  [[ $FileExist && $FileMethodCode = "Relate" ]] && FileMethodLabel="已发现 -> 涉及"
  [[ $FileExist && $FileMethodCode = "Handle" ]] && FileMethodLabel="已发现 -> 备份 -> 修改"
  [[ $FileExist && $FileMethodCode = "Remove" ]] && FileMethodLabel="已发现 -> 备份 -> 删除"

  echo -e "${Space16}[FS    ] [${FileMethodLabel}] $FilePath"
}

# 解析文本 获取数据
# dzFsMatch $FilePath $Sed
dzFsMatch() {
  FilePath=$1
  Sed=$2

  sed -rz -e "$Sed" $FilePath
}

# 在系统中 获取文件
# dzFsGet $FilePath $Source
dzFsGet() {
  FilePath=$1
  Source=$2

  if [[ $Source =~ ^http ]]; then
    if [[ $(rpm -qa | grep wget) ]]; then
      wget -t0 -T5 -O $FilePath $Source --no-check-certificate
    else
      curl -fsSL $Source >$FilePath
    fi
  else
    [[ ! -f $Source && ! -d $Source ]] && dzLogError "${Source} is not found" && exit 0

    if [[ -f $Source ]]; then
      /bin/cp -fa $Source $FilePath
    fi

    if [[ -d $Source ]]; then
      rm -rf $FilePath
      mkdir -p $FilePath
      /bin/cp -fa $Source/* $FilePath
    fi
  fi
}

# 在系统中 备份并删除文件
# dzFsRm $FilePath
dzFsRm() {
  FilePath=$1

  TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")

  [[ ! -f $FilePath && ! -d $FilePath ]] && dzLogError "dzFsRm: ${FilePath} is not found"

  if [[ -f $FilePath ]]; then
    mv $FilePath $FilePath-$TimeFlag.dzdel.bak
  fi

  if [[ -d $FilePath ]]; then
    tar -czPf $FilePath.tar.gz-$TimeFlag.dzdel.bak $FilePath &&
      rm -rf $FilePath
  fi

}

# 压缩
# dzTarC $FilePath $Dir
dzTarC() {
  FilePath=$1
  Dir=$2

  tar -czvPf $FilePath $Dir
}

# 解压
# dzTarX $FilePath $Dir
dzTarX() {
  FilePath=$1
  Dir=$2

  mkdir -p $Dir
  tar -xzf $FilePath -C $Dir
}

# registeBin $CliName $Source
registeBin() {
  CliName=$1
  Source=$2

  [[ ! -f $Source ]] && dzLogError "${Source} is not found" && exit

  chmod u+x $Source
  ln -fs $Source /bin/$CliName
}

# [TODO] 复制目录
# cpDir $Source $Target
cpDir() {
  Source=$1
  Target=$2

  rm -fr $Target
  mkdir -p $Target
  /bin/cp -fa $Source/* $Target
}

StageNo=1

# 该脚本是用来拉取安装包的

logStage $StageNo "设置 DzCloudPath"
DzCloudPath=$1
[[ ! $DzCloudPath =~ ^\/ ]] && dzLogError "DzCloudPath is invalid" && exit 0
mkdir -p $DzCloudPath
let StageNo+=1

logStage $StageNo "获取包信息"
DzCloudGitApiJson=$DzCloudPath/dz-cloud.git.json
DzCloudGitApiJsonSource=https://api.github.com/repos/zhangzj97/cloud-file/releases/latest
dzLogFs $DzCloudGitApiJson "Handle" &&
  dzFsGet $DzCloudGitApiJson $DzCloudGitApiJsonSource
let StageNo+=1

logStage $StageNo "获取版本信息"
TagName=$(dzFsMatch $DzCloudGitApiJson 's|^.*"tag_name": "([^"]*)".*$|\1|g')
dzLogInfo "最新版本 $TagName"
let StageNo+=1

logStage $StageNo "获取包"
DzCloudTar=$DzCloudPath/dz-cloud.tar.gz
DzCloudPackageRaw=$DzCloudPath/zhangzj97-cloud-file-*[^.dzdel.bak]
DzCloudPackage=$DzCloudPath/cloud-file
DzCloudTarSource=$(dzFsMatch $DzCloudGitApiJson 's|^.*"tarball_url": "([^"]*)".*$|\1|g')
dzLogFs $DzCloudTar "Handle" &&
  dzFsGet $DzCloudTar $DzCloudTarSource &&
  dzTarX $DzCloudTar $DzCloudPath
dzLogFs $DzCloudPackage "Handle" &&
  dzFsGet $DzCloudPackage $DzCloudPackageRaw
let StageNo+=1

logStage $StageNo "注册 /bin"
DzAdmSh=$DzCloudPackage/CentOS7/volume/tmp/dzadm/index.sh
DzCtlSh=$DzCloudPackage/CentOS7/volume/tmp/dzctl/index.sh

dzLogInfo "注册 dzadm" && registeBin dzadm $DzAdmSh
dzLogInfo "注册 dzctl" && registeBin dzctl $DzCtlSh
let StageNo+=1

# 清理
logStage $StageNo "清理"
dzLogFs $DzCloudGitApiJson "Remove" && dzFsRm $DzCloudGitApiJson
dzLogFs $DzCloudPackageRaw "Remove" && dzFsRm $DzCloudPackageRaw
dzLogFs $DzCloudTar "Remove" && dzFsRm $DzCloudTar
let StageNo+=1
