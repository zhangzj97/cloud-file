#!/bin/bash -i

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
    wget -t0 -T5 -O $DzTmpFsFilePath $Source --no-check-certificate
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

  if [[ $(rpm -qa | grep $RpmName) ]]; then
    dzLogInfo "[已安装] => $RpmName "
    return
  fi

  if [[ $RemoteFlag && ! -f $DzTmpFsRpmName && ! $(rpm -qa | grep wget) ]]; then
    curl -fsSL $Source >$DzTmpFsRpmName
  elif [[ $RemoteFlag && ! -f $DzTmpFsRpmName && $(rpm -qa | grep wget) ]]; then
    wget -t0 -T5 -O $DzTmpFsRpmName $Source --no-check-certificate
  fi

  if [[ $RemoteFlag ]]; then
    rpm -ivh $DzTmpFsRpmName
  elif [[ ! $RemoteFlag ]]; then
    yum -y -q $RpmName
  fi

  dzLogInfo "[新安装] => $RpmName"
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
