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

  __ServerCert__=$SSLPath/server.cert
  __ServerKey__=$SSLPath/server.key
  # TODO
  __CaCrt__=/etc/docker/certs.d/ca.crt

  __HttpPort__=
  __HttpsPort__=$Port

  dzTmpFsPush $File &&
    dzTmpFsEdit $File "s|__ServerCert__|$__ServerCert__|g" &&
    dzTmpFsEdit $File "s|__ServerKey__|$__ServerKey__|g" &&
    dzTmpFsEdit $File "s|__CaCrt__|$__CaCrt__|g" &&
    dzTmpFsEdit $File "s|__HttpPort__|$__HttpPort__|g" &&
    dzTmpFsEdit $File "s|__HttpsPort__|$__HttpsPort__|g" &&
    dzTmpFsPull $File

}

FileHanlderHarborYml() {
  File=$DCPath/harbor.yml

  __hostname__ =$Domain
  __https_port__=$Port
  __https_certificate__=$SSLPath/server.cert
  __https_private_key__=$SSLPath/server.key
  __harbor_admin_password__=123123
  __data_volume__=/var/lib/docker/volumes/dz-harbor-data
  __log_local_location__=/var/log/harbor

  dzTmpFsPush $File &&
    dzTmpFsEdit $File "s|__hostname__|$__hostname__|g" &&
    dzTmpFsEdit $File "s|__https_port__|$__https_port__|g" &&
    dzTmpFsEdit $File "s|__https_certificate__|$__https_certificate__|g" &&
    dzTmpFsEdit $File "s|__https_private_key__|$__https_private_key__|g" &&
    dzTmpFsEdit $File "s|__harbor_admin_password__|$__harbor_admin_password__|g" &&
    dzTmpFsEdit $File "s|__data_volume__|$__data_volume__|g" &&
    dzTmpFsEdit $File "s|__log_local_location__|$__log_local_location__|g" &&
    dzTmpFsPull $File
}

###################################################################################################
## 业务
###################################################################################################
StageNo=1

# TODO
DCPath=/etc/dz/docker-compose/dz-harbor
SSLPath=/etc/docker/certs.d/$Domain--$Port

dzLogStage $StageNo "开始安装"
dzLogInfo "检查 SSL"
CheckSSL
dzLogInfo "准备基础文件"
for file in $(find $DCPath -type f); do
  FileHanlder $file
done
dzLogInfo "修改初始化文件并执行安装流程"
FileHanlderHarborYml
chmod u+x $DCPath/install.sh
chmod u+x $DCPath/prepare
$DCPath/install.sh
dzLogInfo "准备镜像"
dzLogInfo "准备 处理 .env"
FileHanlderEnv
dzLogInfo "开始部署"
docker compose -f $DCPath/docker-compose.yml up -d
dzLogInfo "[访问] $Domain:$Port"
let StageNo+=1
