#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l web:,cli: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --web)
    WebMode=$2 && shift 2
    ;;
  --cli)
    CliMode=$2 && shift 2
    ;;
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!" && exit 1
    ;;
  esac
done

StageNo=0

if [[ $WebMode ]]; then
  logStage $StageNo "Deploy Docker Dashboard WebMode"
  docker pull joinsunsoft/docker.ui &&
    docker tag joinsunsoft/docker.ui dz-dashboard-docker-ui:1.0.0 # !!! 不是 docker.ui
  docker pull portainer/portainer-ce &&
    docker tag portainer/portainer-ce dz-dashboard-portainer-ce:1.0.0
  docker compose -f $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/dz/docker-compose/dz-dashboard/docker-compose.yml up -d &&
    logStep "192.168.226.100:9001 ==> " &&
    logStep "192.168.226.100:9002 ==> " &&
    logFile $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/dz/docker-compose/dz-dashboard/docker-compose.yml
  let StageNo+=1
fi

if [[ $CliMode ]]; then
  logStage $StageNo "Deploy Docker Dashboard CliMode"
  docker pull lazyteam/lazydocker &&
    docker tag lazyteam/lazydocker dz-dashboard-lazydocker:1.0.0
  docker compose -f $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/docker-compose/dz-dashboard-lazydocker/docker-compose.yml up &&
    logFile $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/docker-compose/dz-dashboard-lazydocker/docker-compose.yml
  let StageNo+=1
fi
