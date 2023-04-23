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

logStage $StageNo "First Stage Description"

if [[ ! $(docker --version) ]]; then
  /bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/yum.repos.d/dz-docker.repo /etc/yum.repos.d/dz-docker.repo
  yum install -y -q docker-ce
fi
logStep "Install: enable docker"
systemctl enable --now docker
logStep "Install: update /etc/docker/daemon.json"
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/docker/daemon.json /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker

# [Stage04] InstallCompose | Install docker compose
logStage "${StageRemark[4]}"

# [Stage05] InstallDashboard | Install docker dashboard
logStage "${StageRemark[5]}"
# [Docker]
docker compose -f $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins/dz-docker/methods/apply/dz-dashboard-docker.ui/docker-compose.yml up -d
docker compose -f $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins/dz-docker/methods/apply/dz-dashboard-portainer/docker-compose.yml up -d

# [Stage06] InstallTest | Install test for docker
logStage "${StageRemark[6]}"

# Other
echo ""
echo ""

[[ ! $(docker images | grep joinsunsoft/docker.ui) ]] && echo 1
