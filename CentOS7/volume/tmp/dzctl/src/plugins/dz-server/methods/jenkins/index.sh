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

StageNo=1

dzLogStage $StageNo "检查 Jenkins"
ServerDomainPort=$Domain--$Port
ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
CaCrt=/etc/docker/certs.d/ca.crt
[[ ! -f $ServerKey ]] && dzLogError "File $ServerKey is not found" && exit
dzLogInfo "准备镜像"
dzImage dz-server/jenkins:1.0.0 jenkins/jenkins:lts-jdk11
dzImage jenkins/ssh-agent:latest
dzLogInfo "准备 Docker compose file"
DzDCY=/etc/dz/docker-compose/dz-jenkins/docker-compose.yml
DzEnv=/etc/dz/docker-compose/dz-jenkins/.env
DzEnv__ServerCert=$ServerCert
DzEnv__ServerKey=$ServerKey
DzEnv__CaCrt=$CaCrt
DzEnv__HttpPort=9021
DzEnv__HttpsPort=9022
dzTmpFsPull $DzDCY "TmpFsRemove" && dzTmpFsPush $DzDCY && dzTmpFsPull $DzDCY
dzTmpFsPull $DzEnv "TmpFsRemove" &&
  dzTmpFsPush $DzEnv &&
  dzTmpFsEdit $DzEnv "s|__ServerCert__|$DzEnv__ServerCert|g" &&
  dzTmpFsEdit $DzEnv "s|__ServerKey__|$DzEnv__ServerKey|g" &&
  dzTmpFsEdit $DzEnv "s|__CaCrt__|$DzEnv__CaCrt|g" &&
  dzTmpFsEdit $DzEnv "s|__HttpPort__|$DzEnv__HttpPort|g" &&
  dzTmpFsEdit $DzEnv "s|__HttpsPort__|$DzEnv__HttpsPort|g" &&
  dzTmpFsPull $DzEnv
dzLogInfo "开始部署"
docker compose -f $DzDCY up -d
dzLogInfo "[访问] $Domain:$Port"
let StageNo+=1
