# DzTool

## 日志模块 dz-log

- dzLogStage $StageNo $Description
- dzLogInfo $Description
- dzLogWarning $Description
- dzLogError $Description

```bash
# 日志 - 阶段
# dzLogStage $StageNo $Description
dzLogStage () {}

# 日志 - Level Info
# dzLogInfo $Description
dzLogInfo () {}

# 日志 - Level Warning
# dzLogWarning $Description
dzLogWarning () {}

# 日志 - Level Error
# dzLogError $Description
dzLogError () {}

```

## 文件模块 dz-fs 建议只在终端使用

- dzFsEdit $FilePath $Sed
- dzFsMatch $FilePath $Sed
- dzFsRm $FilePath
- dzFsBak $FilePath
- dzFsDir $FilePath

## 备份空间文件模块 dz-bakfs

- dzBakFsPush $FilePath
- dzBakFsClear

```bash
# 备份空间 备份
# dzBakFsPush $FilePath
dzBakFsPush () {}

# 备份空间 清除
# dzBakFsClear
dzBakFsClear () {}

```

## 临时空间文件模块 dz-tmpfs

- dzTmpFsPush $FilePath $RemoteSource
- dzTmpFsPush $FilePath $Source
- dzTmpFsPush $FilePath $Source/TmpFsKeep
- dzTmpFsPush $FilePath
- dzTmpFsEdit $FilePath $Sed
- dzTmpFsMatch $FilePath $Sed
- dzTmpFsPull $FilePath
- dzTmpFsPull $FilePath TmpFsRemove
- dzTmpFsPull $FilePath TmpFsBackup

```bash
# 在 TmpFs 添加内容
# dzTmpFsPush $FilePath
# dzTmpFsPush $FilePath $RemoteSource
# dzTmpFsPush $FilePath $Source
# dzTmpFsPush $FilePath $Source/TmpFsKeep
dzTmpFsPush () {}

# 编辑文件内容
# dzTmpFsEdit $FilePath $Sed
dzTmpFsEdit () {}

# 正则匹配内容获取字段
# dzTmpFsMatch $FilePath $Sed
dzTmpFsMatch () {}

# 从 TmpFs 获取内容
# dzTmpFsPull $FilePath
# dzTmpFsPull $FilePath TmpFsRemove
# dzTmpFsPull $FilePath TmpFsBackup
dzTmpFsPull () {}

```

## 未分类模块 dz-other

- dzTarC $FilePath $Source
- dzTarX $FilePath $Target
- dzRpm $RpmName $CheckName
- dzLinkFile $FilePath $BinName

```bash
# Tar 压缩
# dzTarC $FilePath $Source
dzTarC () {}

# Tar 解压
# dzTarX $FilePath $Target
dzTarX () {}

# Rpm
# dzRpm $RpmName $Source
dzRpm() {}

# 关联
# dzLinkFile $BinName $Source
dzLinkFile () {}

# 下载镜像
# dzImage $NewTag $Source
dzImage() {}

```
