#!/bin/bash -i

DzCloudPath=$1
DzTmpFsPath=$DzCloudPath/.tmpfs
DzBakFsPath=$DzCloudPath/.bakfs
DzVolFsPath=$DzCloudPath/.volfs

DZ_CLOUD_PATH=$DzCloudPath
DZ_TMP_FS_PATH=$DzTmpFsPath
DZ_BAK_FS_PATH=$DzBakFsPath
DZ_VOL_FS_PATH=$DzVolFsPath

[[ ! $DzCloudPath =~ ^\/ ]] && echo "DzCloudPath is invalid" && exit 0
mkdir -p $DzCloudPath
mkdir -p $DzTmpFsPath
mkdir -p $DzBakFsPath

###################################################################################################
## 日志模块 dz-log
###################################################################################################

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

# 日志 - 阶段
# dzLogStage $StageNo $Description
dzLogStage() {
  StageNo=$1
  Description=$2

  echo ""
  echo -e "${Space16}${TextBlue}============================================================"
  echo -e "${Space16}${TextBlue}[Stage$StageNo] $Description${TextClear}"
}

# 日志 - Level Info
# dzLogInfo $Description
dzLogInfo() {
  Description=$1

  echo -e "${Space16}[INFO   ] $Description"
}

# 日志 - Level Warning
# dzLogWarning $Description
dzLogWarning() {
  Description=$1

  echo -e "${Space16}${TextYellow}[WARNING] $Description${TextClear}"
}

# 日志 - Level Error
# dzLogError $Description
dzLogError() {
  Description=$1

  echo -e "${Space16}${TextRed}[ERROR  ] $Description${TextClear}"
}

###################################################################################################
## 临时空间文件模块 dz-tmp-fs
###################################################################################################

# 在 TmpFs 添加内容
# dzTmpFsPush $FilePath
# dzTmpFsPush $FilePath $RemoteSource
# dzTmpFsPush $FilePath $Source
# dzTmpFsPush $FilePath $Source/TmpFsKeep
dzTmpFsPush() {
  DzTmpFsPath=$DZ_TMP_FS_PATH
  TmpFsRemove="TmpFsRemove"
  TmpFsRemove="TmpFsRemove"

  # 验证 FilePath
  # 1. 有
  # 2. 不在根目录下
  # 3. 有文件名称
  FilePath=$1
  FilePathDir=${FilePath%/*}
  FilePathFileName=${FilePath##*/}
  DzTmpFsFilePath=$DzTmpFsPath$FilePath
  DzTmpFsFilePathDir=$DzTmpFsPath$FilePathDir
  DzBakFsFilePath=$DzBakFsPath$FilePath
  DzBakFsFilePathDir=$DzBakFsPath$FilePathDir

  [[ ! $FilePath ]] && dzLogError "dzTmpFsPush => FilePath is required" && exit
  [[ $FilePathDir = / ]] && dzLogError "dzTmpFsPush => FilePathDir is /, please change another" && exit
  [[ ! $FilePathFileName ]] && dzLogError "dzTmpFsPush => FilePath : FilePathFileName is invalid" && exit

  # 验证 Source
  # 1. 如果没有, 默认 Source=FilePath
  # 2. 如果 http 开头, 远程下载
  # 3. 如果是本地文件
  #   3.1 如果不存在 => 在 tmpfs 新建一个空文件
  #   3.2 如果存在 => 复制到 tmpfs
  Source=$2
  RemoteFlag=
  [[ ! $Source ]] && Source=$FilePath
  [[ $Source =~ http ]] && RemoteFlag=1

  # 重置 tmpfs 空间
  rm -rf $FilePathFileName
  mkdir -p $FilePathDir
  mkdir -p $DzTmpFsFilePathDir

  # 获取 Source
  if [[ $RemoteFlag && ! $(rpm -qa | grep wget) ]]; then
    curl -fsSL $Source >$DzTmpFsFilePath
    dzLogInfo "[下载文件] $DzTmpFsFilePath"
  elif [[ $RemoteFlag && $(rpm -qa | grep wget) ]]; then
    wget -q -t0 -T5 -O $DzTmpFsFilePath $Source --no-check-certificate
    dzLogInfo "[下载文件] $DzTmpFsFilePath"
  elif [[ ! $RemoteFlag && ! -f $Source ]]; then
    touch $DzTmpFsFilePath
  elif [[ ! $RemoteFlag && -f $Source ]]; then
    /bin/cp -fa $Source $DzTmpFsFilePath
  fi
}

# 编辑文件内容
# dzTmpFsEdit $FilePath $Sed
dzTmpFsEdit() {
  FilePath=$1
  FilePathDir=${FilePath%/*}
  FilePathFileName=${FilePath##*/}
  DzTmpFsFilePath=$DzTmpFsPath$FilePath
  DzTmpFsFilePathDir=$DzTmpFsPath$FilePathDir
  DzBakFsFilePath=$DzBakFsPath$FilePath
  DzBakFsFilePathDir=$DzBakFsPath$FilePathDir
  Sed=$2

  [[ ! -f $DzTmpFsFilePath ]] && dzLogError "dzTmpFsEdit => ${DzTmpFsFilePath} is not found" && exit
  [[ ! -s $DzTmpFsFilePath ]] && echo "    " >$DzTmpFsFilePath && echo "" >$DzTmpFsFilePath

  sed -r -i "$Sed" $DzTmpFsFilePath
}

# 正则匹配内容获取字段
# dzTmpFsMatch $FilePath $Sed
dzTmpFsMatch() {
  FilePath=$1
  FilePathDir=${FilePath%/*}
  FilePathFileName=${FilePath##*/}
  DzTmpFsFilePath=$DzTmpFsPath$FilePath
  DzTmpFsFilePathDir=$DzTmpFsPath$FilePathDir
  DzBakFsFilePath=$DzBakFsPath$FilePath
  DzBakFsFilePathDir=$DzBakFsPath$FilePathDir
  Sed=$2

  [[ ! -f $FilePath ]] && dzLogError "dzTmpFsMatch => ${DzTmpFsFilePath} is not found" && exit

  sed -rz -e "$Sed" $DzTmpFsFilePath
}

# 从 TmpFs 获取内容 并 记录与备份 (仅仅支持获取同名文件)
# dzTmpFsPull $FilePath
# dzTmpFsPull $FilePath $TmpFsCode
dzTmpFsPull() {
  DzTmpFsPath=$DZ_TMP_FS_PATH
  DzBakFsPath=$DZ_BAK_FS_PATH
  TmpFsRemove="TmpFsRemove"

  # 验证 FilePath
  # 临时空间和本地空间文件同名
  # 1. 先判断是否有 TmpFsCode, 有则优先执行
  # 2. 没有 TmpFsCode, 临时空间没有, 报错
  # 3. 没有 TmpFsCode, 临时空间有
  #   3.2 本地空间没有 直接获取
  #   3.1 本地空间有 备份并替换
  FilePath=$1
  FilePathDir=${FilePath%/*}
  FilePathFileName=${FilePath##*/}
  DzTmpFsFilePath=$DzTmpFsPath$FilePath
  DzTmpFsFilePathDir=$DzTmpFsPath$FilePathDir
  DzBakFsFilePath=$DzBakFsPath$FilePath
  DzBakFsFilePathDir=$DzBakFsPath$FilePathDir
  TmpFsCode=$2

  # 验证 TmpFsCode
  # 1. 先判断是否有 TmpFsCode, 有则优先执行
  if [[ $TmpFsCode = TmpFsRemove && ! -f $FilePath ]]; then
    dzLogInfo "删除文件 => $FilePath, 不存在"
    return
  elif [[ $TmpFsCode = TmpFsRemove && -f $FilePath ]]; then
    mkdir -p $DzBakFsFilePathDir
    TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")
    /bin/cp -fa $FilePath $DzBakFsPath$FilePath-$TimeFlag.bak
    rm -rf $FilePath
    dzLogInfo "删除文件 => $FilePath, 备份 Path => $DzBakFsPath$FilePath-$TimeFlag.bak"
    return
  fi

  # 验证 FilePath
  # 临时空间和本地空间文件同名
  # 1. 没有 TmpFsCode, 临时空间没有, 报错
  # 2. 没有 TmpFsCode, 临时空间有
  #   2.1 本地空间没有 直接获取
  #   2.2 本地空间有 备份并替换

  if [[ ! -f $DzTmpFsFilePath ]]; then
    dzLogError "dzTmpFsPull => ${DzTmpFsFilePath} is not found" && exit
  elif [[ -f $DzTmpFsFilePath && ! -f $FilePath ]]; then
    /bin/cp -fa $DzTmpFsFilePath $FilePath
    dzLogInfo "新增文件 => $FilePath"
  elif [[ -f $DzTmpFsFilePath && -f $FilePath ]]; then
    mkdir -p $DzBakFsFilePathDir
    TimeFlag=$(date "+%Y-%m-%d%H:%M:%S")
    /bin/cp -fa $FilePath $DzBakFsPath$FilePath-$TimeFlag.bak
    rm -rf $FilePath
    /bin/cp -fa $DzTmpFsFilePath $FilePath
    dzLogInfo "修改文件 => $FilePath, 备份 Path => $DzBakFsPath$FilePath-$TimeFlag.bak"
  fi
}

###################################################################################################
## 未分类模块 dz-other
###################################################################################################

# Tar 压缩
# dzTarC $FilePath $Source
dzTarC() {
  FilePath=$1
  Source=$2

  tar -czvPf $FilePath $Dir
}

# Tar 解压
# dzTarX $FilePath $Target
dzTarX() {
  FilePath=$1
  Target=$2

  mkdir -p $Target
  tar -xzf $FilePath -C $Target
}

# Rpm
# dzRpm $RpmName $Source
dzRpm() {
  DzTmpFsPath=$DZ_TMP_FS_PATH
  DzBakFsPath=$DZ_BAK_FS_PATH

  RpmName=$1
  Source=$2

  DzTmpFsRpmName=$DzTmpFsPath/$RpmName.rpm

  RemoteFlag=
  [[ ! $Source ]] && Source=$RpmName
  [[ $Source =~ http ]] && RemoteFlag=1

  RpmVersion=$(rpm -qa | grep $RpmName)
  if [[ $RpmVersion ]]; then
    dzLogInfo "[已安装] $RpmName => $RpmVersion"
    return
  fi

  if [[ $RemoteFlag && ! -f $DzTmpFsRpmName && ! $(rpm -qa | grep wget) ]]; then
    curl -fsSL $Source >$DzTmpFsRpmName
  elif [[ $RemoteFlag && ! -f $DzTmpFsRpmName && $(rpm -qa | grep wget) ]]; then
    wget -q -t0 -T5 -O $DzTmpFsRpmName $Source --no-check-certificate
  fi

  if [[ $RemoteFlag ]]; then
    rpm -ivh $DzTmpFsRpmName
  elif [[ ! $RemoteFlag ]]; then
    yum install -y -q $RpmName
  fi

  RpmVersion=$(rpm -qa | grep $RpmName)
  dzLogInfo "[新安装] => $RpmName => $RpmVersion"
}

# 关联
# dzLinkFile $BinName $Source
dzLinkFile() {
  BinName=$1
  Source=$2

  [[ ! -f $Source ]] && dzLogError "${Source} is not found" && exit 0

  chmod u+x $Source
  ln -fs $Source /bin/$BinName

  dzLogInfo "[链接] $BinName => $Source"
}

###################################################################################################
## 业务
###################################################################################################

StageNo=1

# 该脚本是用来拉取安装包的

DzCloudPath=$1
DzTmpFsPath=$DzCloudPath/.tmpfs
DzBakFsPath=$DzCloudPath/.bakfs

dzLogStage $StageNo "设置 DzCloudPath"
[[ ! $DzCloudPath =~ ^\/ ]] && dzLogError "DzCloudPath is invalid" && exit 0
dzLogInfo "DzCloudPath => $DzCloudPath"
dzLogInfo "DzTmpFsPath => $DzTmpFsPath"
dzLogInfo "DzBakFsPath => $DzBakFsPath"
dzLogInfo "DzVolFsPath => $DzVolFsPath"
mkdir -p $DzCloudPath
mkdir -p $DzTmpFsPath
mkdir -p $DzBakFsPath
mkdir -p $DzVolFsPath
let StageNo+=1

dzLogStage $StageNo "获取相关信息"
DzCloudGitApiJson=$DzCloudPath/dz-cloud.git.json
DzCloudGitApiJsonSource=https://api.github.com/repos/zhangzj97/cloud-file/releases/latest
dzTmpFsPush $DzCloudGitApiJson $DzCloudGitApiJsonSource &&
  dzTmpFsPull $DzCloudGitApiJson
dzLogInfo "获取版本信息"
TagName=$(dzTmpFsMatch $DzCloudGitApiJson 's|^.*"tag_name": "([^"]*)".*$|\1|g')
dzLogInfo "最新版本 => $TagName"
let StageNo+=1

dzLogStage $StageNo "获取包"
DzCloudTar=$DzCloudPath/dz-cloud.tar.gz
DzCloudPackageRaw=$DzCloudPath/zhangzj97-cloud-file-*
DzCloudPackage=$DzCloudPath/cloud-file
DzCloudTarSource=$(dzTmpFsMatch $DzCloudGitApiJson 's|^.*"tarball_url": "([^"]*)".*$|\1|g')
dzTmpFsPush $DzCloudTar $DzCloudTarSource &&
  dzTmpFsPull $DzCloudTar
dzTarX $DzCloudTar $DzCloudPath
/bin/cp -fa $DzCloudPackageRaw $DzCloudPackage
/bin/cp -fa $DzCloudPackage/CentOS7/volume/* $DzVolFsPath
rm -rf $DzCloudPackageRaw
let StageNo+=1

dzLogStage $StageNo "注册全局指令 /bin"
DzAdmIndexSh=$DzCloudPath/cloud-file/CentOS7/volume/tmp/dzadm/index.sh
DzCtlIndexSh=$DzCloudPath/cloud-file/CentOS7/volume/tmp/dzctl/index.sh
dzLinkFile dzadm $DzAdmIndexSh
dzLinkFile dzctl $DzCtlIndexSh
let StageNo+=1

dzLogStage $StageNo "注册全局参数 /etc/profile.d/dzadm.sh"
TagName=$(dzTmpFsMatch $DzCloudGitApiJson 's|^.*"tag_name": "([^"]*)".*$|\1|g')

ProfileDDzAdmSh=/etc/profile.d/dzadm.sh
dzTmpFsPush $ProfileDDzAdmSh &&
  dzTmpFsEdit $ProfileDDzAdmSh "/^.*$/d" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a #!/bin/bash -i" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a DZ_CLOUD_VERSION=${TagName}" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a DZ_CLOUD_PATH=${DzCloudPath}" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a DZ_TMP_FS_PATH=${DzTmpFsPath}" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a DZ_BAK_FS_PATH=${DzBakFsPath}" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a DZ_VOL_FS_PATH=${DzVolFsPath}" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a DZ_TOOL_PATH=${DzCloudPath}/cloud-file/CentOS7/volume/tmp/dztool/index.sh" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a export DZ_CLOUD_VERSION" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a export DZ_CLOUD_PATH" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a export DZ_TMP_FS_PATH" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a export DZ_BAK_FS_PATH" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a export DZ_VOL_FS_PATH" &&
  dzTmpFsEdit $ProfileDDzAdmSh "\$a export DZ_TOOL_PATH" &&
  dzTmpFsPull $ProfileDDzAdmSh
source /etc/profile
let StageNo+=1

dzLogStage $StageNo "第三方软件 repo 源"
YumReposD=/etc/yum.repos.d
for FileName in $(ls $DzVolFsPath/$YumReposD); do
  dzTmpFsPush $YumReposD/$FileName &&
    dzTmpFsPull $YumReposD/$FileName
done
let StageNo+=1

dzLogStage $StageNo "安装常用第三方软件"
dzRpm vim-enhanced vim
dzRpm wget
let StageNo+=1

dzLogStage $StageNo "清理"
dzTmpFsPush $DzCloudGitApiJson &&
  dzTmpFsPull $DzCloudGitApiJson "TmpFsRemove"
dzTmpFsPush $DzCloudTar &&
  dzTmpFsPull $DzCloudTar "TmpFsRemove"
let StageNo+=1

dzLogStage $StageNo "Note"
dzLogInfo "修改基础信息 => dzctl host set --ip=[static ip] --name=[hostname]"
dzLogInfo "添加 ssl     => dzctl ssl apply"
dzLogInfo "你可以先部署 docker => dzctl docker apply"
dzLogInfo "可部署列表: harbor rancher k8s 等"
let StageNo+=1
