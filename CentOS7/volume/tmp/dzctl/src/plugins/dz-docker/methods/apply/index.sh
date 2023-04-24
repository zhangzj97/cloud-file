#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l a1:,a2: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!" && exit 1
    ;;
  esac
done

StageNo=0

logStage $StageNo "Install Docker"
dzYum docker-ce
systemctl enable --now docker
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/docker/daemon.json /etc/docker/daemon.json &&
  systemctl daemon-reload &&
  systemctl restart docker &&
  logFile /etc/docker/daemon.json

logStage $StageNo "Deploy Docker Dashboard"
docker pull joinsunsoft/docker.ui &&
  docker tag joinsunsoft/docker.ui dz-dashboard-docker.ui:1.0.0
docker pull portainer/portainer-ce &&
  docker tag portainer/portainer-ce dz-dashboard-portainer-ce:1.0.0
docker compose -f $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/docker-compose/dz-dashboard/docker-compose.yml up -d &&
  logFile $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/docker-compose/dz-dashboard/docker-compose.yml
