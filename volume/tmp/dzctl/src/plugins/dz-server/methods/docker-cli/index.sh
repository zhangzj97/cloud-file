#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l domain:,port:, -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --domain)
    Domain=$2 && shift 2
    ;;
  --port)
    Port=$2 && shift 2
    ;;
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit 1
    ;;
  esac
done
if [[ ! $Domain ]]; then
  IfcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
  dzTmpFsPush $IfcfgPath &&
    StaticIp=$(dzTmpFsMatch $IfcfgPath 's|^.*IPADDR="?([^"]*)"?.*$|\1|g')
  Domain=$StaticIp
fi
# [[ ! $Port ]] && dzLogError "option --port is invalid" && exit 0

###################################################################################################
## SSL
###################################################################################################
CheckSSL() {
  SSLKey=$SSLPath/server.key

  [[ ! -f $SSLKey ]] && dzLogError "File $SSLKey is not found" && exit
}

###################################################################################################
## 文件处理
###################################################################################################
FileHanlder() {
  File=$1

  dzTmpFsPull $File "TmpFsRemove" && dzTmpFsPush $File && dzTmpFsPull $File
}

FileHanlderEnv() {
  File=$DCPath/.env

  __BasePath__=$DCPath
  __VolumePath__=$DCPath/volume

  __ServerCert__=$SSLPath/server.cert
  __ServerKey__=$SSLPath/server.key
  # TODO
  __CaCrt__=/etc/docker/certs.d/ca.crt

  __HttpPort__=$(($Port - 1))
  __HttpsPort__=$Port

  dzTmpFsPush $File &&
    dzTmpFsEdit $File "s|__BasePath__|$__BasePath__|g" &&
    dzTmpFsEdit $File "s|__VolumePath__|$__VolumePath__|g" &&
    dzTmpFsEdit $File "s|__ServerCert__|$__ServerCert__|g" &&
    dzTmpFsEdit $File "s|__ServerKey__|$__ServerKey__|g" &&
    dzTmpFsEdit $File "s|__CaCrt__|$__CaCrt__|g" &&
    dzTmpFsEdit $File "s|__HttpPort__|$__HttpPort__|g" &&
    dzTmpFsEdit $File "s|__HttpsPort__|$__HttpsPort__|g" &&
    dzTmpFsPull $File

}

###################################################################################################
## 业务
###################################################################################################
StageNo=1

# TODO
DCPath=/etc/dz-server/dz-docker-cli
# SSLPath=/etc/docker/certs.d/$Domain--$Port

dzLogStage $StageNo "开始安装"
dzLogInfo "检查 SSL"
# CheckSSL
dzLogInfo "准备基础文件"
for file in $(find $DZ_VOL_FS_PATH$DCPath -type f); do
  FileHanlder ${file##$DZ_VOL_FS_PATH}
done
dzLogInfo "修改初始化文件并执行安装流程"
dzLogInfo "准备镜像"
dzImage dz-server/lazydocker:1.0.0 lazyteam/lazydocker:latest
dzLogInfo "准备 处理 .env"
FileHanlderEnv
dzLogInfo "开始部署"
docker compose -f $DCPath/docker-compose.yml run dz-lazydocker
let StageNo+=1
