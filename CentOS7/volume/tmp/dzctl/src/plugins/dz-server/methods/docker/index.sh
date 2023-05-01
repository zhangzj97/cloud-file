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
dzRpm docker
systemctl enable --now docker
DaemonJson=/etc/docker/daemon.json
dzTmpFsPush $DaemonJson &&
  dzTmpFsPull $DaemonJson
systemctl daemon-reload
systemctl restart docker
let StageNo+=1

dzLogStage $StageNo "安装 Docker Dashboard Web"
if [[ ! $WebMode = 0 ]]; then
  DzDockerDashboardWebDC=/etc/dz/docker-compose/dz-docker-dashboard-web/docker-compose.yml
  dzTmpFsPush $DzDockerDashboardWebDC &&
    dzTmpFsPull $DzDockerDashboardWebDC
  docker pull joinsunsoft/docker.ui &&
    docker tag joinsunsoft/docker.ui dz-dashboard-docker-ui:1.0.0
  docker pull portainer/portainer-ce &&
    docker tag portainer/portainer-ce dz-dashboard-portainer-ce:1.0.0
  docker compose -f $DzDockerDashboardWebDC up -d
  docker rmi joinsunsoft/docker.ui
  docker rmi portainer/portainer-ce
  dzLogInfo "[访问] 192.168.226.100:9001"
  dzLogInfo "[访问] 192.168.226.100:9002"
  let StageNo+=1
else
  dzLogInfo "不部署 Docker Dashboard Web"
  let StageNo+=1
fi
