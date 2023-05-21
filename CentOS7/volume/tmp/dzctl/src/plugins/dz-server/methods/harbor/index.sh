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
[[ ! $Domain ]] && dzLogError "option --domain is invalid" && exit 0
[[ ! $Port ]] && dzLogError "option --port is invalid" && exit 0

###################################################################################################
## 业务
###################################################################################################

###################################################################################################
## 文件处理
###################################################################################################
FileHanlder() {
  File=$1

  dzTmpFsPull $File "TmpFsRemove" && dzTmpFsPush $File && dzTmpFsPull $File
}

FileHanlderEnv() {
  File=$DzDCPath/.env

  __ServerCert__=$ServerCert
  __ServerKey__=$ServerKey
  __CaCrt__=$CaCrt
  __HttpPort__=9031
  __HttpsPort__=9032

  dzTmpFsPush $File &&
    dzTmpFsEdit $File "s|__ServerCert__|$__ServerCert__|g" &&
    dzTmpFsEdit $File "s|__ServerKey__|$__ServerKey__|g" &&
    dzTmpFsEdit $File "s|__CaCrt__|$__CaCrt__|g" &&
    dzTmpFsEdit $File "s|__HttpPort__|$__HttpPort__|g" &&
    dzTmpFsEdit $File "s|__HttpsPort__|$__HttpsPort__|g" &&
    dzTmpFsPull $File

}

FileHanlderHarborYml() {
  File=$DzDCPath/harbor.yml

  __hostname__ =$Domain
  __https_port__=$Port
  __https_certificate__=$ServerCert
  __https_private_key__=$ServerKey
  __harbor_admin_password__=123123
  __data_volume__=/var/lib/docker/volumes/dz-harbor-data
  __log_local_location__=/var/log/harbor

  dzTmpFsPush $DzInstall &&
    dzTmpFsEdit $DzInstall "s|__hostname__|$__hostname__|g" &&
    dzTmpFsEdit $DzInstall "s|__https_port__|$__https_port__|g" &&
    dzTmpFsEdit $DzInstall "s|__https_certificate__|$__https_certificate__|g" &&
    dzTmpFsEdit $DzInstall "s|__https_private_key__|$__https_private_key__|g" &&
    dzTmpFsEdit $DzInstall "s|__harbor_admin_password__|$__harbor_admin_password__|g" &&
    dzTmpFsEdit $DzInstall "s|__data_volume__|$__data_volume__|g" &&
    dzTmpFsEdit $DzInstall "s|__log_local_location__|$__log_local_location__|g" &&
    dzTmpFsPull $DzInstall
}

StageNo=1

dzLogStage $StageNo "检查 Harbor"
ServerDomainPort=$Domain--$Port
ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
CaCrt=/etc/docker/certs.d/ca.crt
[[ ! -f $ServerKey ]] && dzLogError "File $ServerKey is not found" && exit
dzLogInfo "准备基础文件"
DzDCPath=/etc/dz/docker-compose/dz-harbor
for file in $(find $DzDCPath -type f); do
  FileHanlder $file
done
dzLogInfo "修改初始化文件并执行安装流程"
FileHanlderHarborYml
chmod u+x $DzDCPath/install.sh
chmod u+x $DzDCPath/prepare
$DzDCPath/install.sh
dzLogInfo "准备镜像"
dzLogInfo "准备 处理 .env"
FileHanlderEnv
dzLogInfo "开始部署"
docker compose -f $DzDCPath/docker-compose.yml up -d
dzLogInfo "[访问] $Domain:$Port"
let StageNo+=1
