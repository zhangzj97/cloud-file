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
DzJenkinsDC=/etc/dz/docker-compose/dz-jenkins/docker-compose.yml
DzJenkinsEnv=/etc/dz/docker-compose/dz-jenkins/.env
DzJenkinsEnv__ServerCert=$ServerCert
DzJenkinsEnv__ServerKey=$ServerKey
DzJenkinsEnv__CaCrt=$CaCrt
DzJenkinsEnv__HttpPort=9021
DzJenkinsEnv__HttpsPort=9022
docker pull jenkins/jenkins:lts-jdk11 &&
  docker tag jenkins/jenkins:lts-jdk11 dz-jenkins:1.0.0
dzTmpFsPush $DzJenkinsDC && dzTmpFsPull $DzJenkinsDC
dzTmpFsPull $DzJenkinsEnv "TmpFsRemove"
dzTmpFsPush $DzJenkinsEnv &&
  dzTmpFsEdit $DzJenkinsEnv "s|__ServerCert__|$DzJenkinsEnv__ServerCert|g" &&
  dzTmpFsEdit $DzJenkinsEnv "s|__ServerKey__|$DzJenkinsEnv__ServerKey|g" &&
  dzTmpFsEdit $DzJenkinsEnv "s|__CaCrt__|$DzJenkinsEnv__CaCrt|g" &&
  dzTmpFsEdit $DzJenkinsEnv "s|__HttpPort__|$DzJenkinsEnv__HttpPort|g" &&
  dzTmpFsEdit $DzJenkinsEnv "s|__HttpsPort__|$DzJenkinsEnv__HttpsPort|g" &&
  dzTmpFsPull $DzJenkinsEnv
docker compose -f $DzJenkinsDC up -d
docker rmi jenkins/jenkins:lts-jdk11
let StageNo+=1

dzLogInfo "[访问] $Domain:$Port"
