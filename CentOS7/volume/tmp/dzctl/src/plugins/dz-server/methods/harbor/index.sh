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

  __BasePath__=$DzDCPath
  __ServerCert__=$ServerCert
  __ServerKey__=$ServerKey
  __CaCrt__=$CaCrt
  __HttpPort__=9004
  __HttpsPort__=$Port
  __HarborVolumePath__=/var/lib/docker/volumes/dz-harbor

  dzTmpFsPull $File "TmpFsRemove" &&
    dzTmpFsPush $File &&
    dzTmpFsEdit $File "s|__BasePath__|$__BasePath__|g" &&
    dzTmpFsEdit $File "s|__ServerCert__|$__ServerCert__|g" &&
    dzTmpFsEdit $File "s|__ServerKey__|$__ServerKey__|g" &&
    dzTmpFsEdit $File "s|__CaCrt__|$__CaCrt__|g" &&
    dzTmpFsEdit $File "s|__HttpPort__|$__HttpPort__|g" &&
    dzTmpFsEdit $File "s|__HttpsPort__|$__HttpsPort__|g" &&
    dzTmpFsEdit $File "s|__HarborVolumePath__|$__HarborVolumePath__|g" &&
    dzTmpFsPull $File
}

StageNo=1

dzLogStage $StageNo "检查 Harbor"
ServerDomainPort=$Domain--$Port
ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
CaCrt=/etc/docker/certs.d/ca.crt
[[ ! -f $ServerKey ]] && dzLogError "File $ServerKey is not found" && exit
DzDCPath=/etc/dz/docker-compose/dz-harbor
dzLogInfo "准备镜像"
dzImage goharbor/harbor-core:v2.8.0
dzImage goharbor/harbor-db:v2.8.0
dzImage goharbor/harbor-jobservice:v2.8.0
dzImage goharbor/harbor-log:v2.8.0
dzImage goharbor/harbor-portal:v2.8.0
dzImage goharbor/harbor-registryctl:v2.8.0
dzImage goharbor/nginx-photon:v2.8.0
dzImage goharbor/redis-photon:v2.8.0
dzImage goharbor/registry-photon:v2.8.0
dzLogInfo "准备 基础文件"
for file in $(find $DzDCPath -type f); do
  FileHanlder $file
done
dzLogInfo "准备 Docker compose file & .env"
DzDCY=$DzDCPath/docker-compose.yml
FileHanlderEnv
dzLogInfo "开始部署"
docker compose -f $DzDCY up -d
dzLogInfo "[访问] $Domain:$Port"
let StageNo+=1
