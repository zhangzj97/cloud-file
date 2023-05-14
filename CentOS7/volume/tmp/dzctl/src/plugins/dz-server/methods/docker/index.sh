#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l web: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --web)
    WebMode=$2 && shift 2
    ;;
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit
    ;;
  esac
done

###################################################################################################
## 业务
###################################################################################################

StageNo=1

dzLogStage $StageNo "安装 Docker"
dzRpm docker-ce
systemctl enable --now docker
DaemonJson=/etc/docker/daemon.json
dzTmpFsPull $DaemonJson "TmpFsRemove" && dzTmpFsPush $DaemonJson && dzTmpFsPull $DaemonJson
systemctl daemon-reload
systemctl restart docker
let StageNo+=1

dzLogStage $StageNo "检查 Docker"
# ServerDomainPort=$Domain--$Port
# ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
# ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
# CaCrt=/etc/docker/certs.d/ca.crt
# [[ ! -f $ServerKey ]] && dzLogError "File $ServerKey is not found" && exit
dzLogInfo "准备镜像"
dzImage dz-server/portainer-ce:1.0.0 portainer/portainer-ce:latest
dzLogInfo "准备 Docker compose file"
DzDCY=/etc/dz/docker-compose/dz-docker/docker-compose.yml
DzEnv=/etc/dz/docker-compose/dz-docker/.env
# DzEnv__ServerCert=$ServerCert
# DzEnv__ServerKey=$ServerKey
# DzEnv__CaCrt=$CaCrt
DzEnv__HttpPort=9001
DzEnv__HttpsPort=9002
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
dzLogInfo "[访问] 192.168.226.xxx:9002"
let StageNo+=1
