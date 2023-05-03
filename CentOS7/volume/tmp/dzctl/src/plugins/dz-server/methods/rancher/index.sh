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

StageNo=0

dzLogStage $StageNo "准备镜像"
DzRancherInstallerFile01=/etc/dz/rancher-installer/rancher-images.txt
DzRancherInstallerFile02=/etc/dz/rancher-installer/rancher-load-images.sh
DzRancherInstallerFile03=/etc/dz/rancher-installer/rancher-save-images.sh
dzTmpFsPush $DzRancherInstallerFile01 && dzTmpFsPull $DzRancherInstallerFile01
dzTmpFsPush $DzRancherInstallerFile02 && dzTmpFsPull $DzRancherInstallerFile02
dzTmpFsPush $DzRancherInstallerFile03 && dzTmpFsPull $DzRancherInstallerFile03
chmod u+x /etc/dz/rancher-installer/rancher-save-images.sh
/etc/dz/rancher-installer/rancher-save-images.sh --from-aliyun true
let StageNo+=1

dzLogStage $StageNo "检查 Rancher"
ServerDomainPort=$Domain--$Port
ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
CaCrt=/etc/docker/certs.d/ca.crt
[[ ! -f $ServerKey ]] && dzLogError "File $ServerKey is not found" && exit
DzRancherDC=/etc/dz/docker-compose/dz-rancher/docker-compose.yml
DzRancherEnv=/etc/dz/docker-compose/dz-rancher/.env
DzRanckerEnv__ServerCert=$ServerCert
DzRanckerEnv__ServerKey=$ServerKey
DzRanckerEnv__CaCrt=$CaCrt
DzRanckerEnv__HttpPort=9011
DzRanckerEnv__HttpsPort=9012
docker pull rancher/rancher:v2.7.2 &&
  docker tag rancher/rancher dz-rancher:1.0.0
dzTmpFsPush $DzRancherDC && dzTmpFsPull $DzRancherDC
dzTmpFsPull $DzRancherEnv "TmpFsRemove"
dzTmpFsPush $DzRancherEnv &&
  dzTmpFsEdit $DzRancherEnv "s|__ServerCert__|$DzRanckerEnv__ServerCert|g" &&
  dzTmpFsEdit $DzRancherEnv "s|__ServerKey__|$DzRanckerEnv__ServerKey|g" &&
  dzTmpFsEdit $DzRancherEnv "s|__CaCrt__|$DzRanckerEnv__CaCrt|g" &&
  dzTmpFsEdit $DzRancherEnv "s|__HttpPort__|$DzRanckerEnv__HttpPort|g" &&
  dzTmpFsEdit $DzRancherEnv "s|__HttpsPort__|$DzRanckerEnv__HttpsPort|g" &&
  dzTmpFsPull $DzRancherEnv
docker compose -f $DzRancherDC up -d
docker rmi rancher/rancher:v2.7.2
let StageNo+=1

dzLogInfo "[访问] $Domain:$Port"
