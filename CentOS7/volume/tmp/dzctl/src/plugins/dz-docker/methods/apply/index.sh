#!/bin/bash -i

RED='\e[1;31m'    # 红
GREEN='\e[1;32m'  # 绿
YELLOW='\e[1;33m' # 黄
BLUE='\e[1;34m'   # 蓝
PINK='\e[1;35m'   # 粉红
RES='\e[0m'       # 清除颜色

logStage() {
  echo ""
  echo ""
  echo -e "${BLUE}                ============================================================"
  echo -e "${BLUE}                $1 ${RES}"
}

logStep() {
  echo -e "                    $1"
}

logResult() {
  echo -e "${GREEN}                                [RESULT] Finish Stage Successfully! ${RES}"
  echo ""
}

logErrorResult() {
  echo -e "${RED}                    [Error] $1 ${RES}"
  echo ""
}

StageRemark=(
  "[Stage00]"
  "[Stage01] Validate          | Validate param"
  "[Stage02] InstallDependency | Install some softwares"
  "[Stage03] InstallDocker     | Install docker"
  "[Stage04] InstallCompose    | Install docker compose"
  "[Stage05] InstallDashboard  | Install docker dashboard"
  "[Stage06] InstallTest       | Install test for docker"
)

# Validate | Validate param
logStage "${StageRemark[1]}"
# [[ $* =~ get ]] && echo Error get && exit

# [Stage02] InstallDependency | Install some softwares
logStage "${StageRemark[2]}"
# [Install] yum-utils
logStep "Install: check package yum-utils"
[[ ! $(rpm -qa | grep yum-utils) ]] && yum install -y -q yum-utils
# TODO yum install libseccomp-devel

# [Stage03] InstallDocker | Install docker
logStage "${StageRemark[3]}"
# [Install] docker
logStep "Install: add docker repo"
if [[ ! $(docker --version) ]]; then
cp /tmp/cloud-file-git/CentOS7_All_001/volume/etc/yum.repos.d/dz-docker.repo /etc/yum.repos.d/dz-docker.repo
yum install -y -q docker-ce
fi
# [Install] Docker service
logStep "Install: enable docker"
systemctl enable --now docker
# [Install] Update daemon.json
logStep "Install: update /etc/docker/daemon.json"
/bin/cp -fa /tmp/cloud-file-git/CentOS7_All_001/volume/etc/docker/daemon.json /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker

# [Stage04] InstallCompose | Install docker compose
logStage "${StageRemark[4]}"

# [Stage05] InstallDashboard | Install docker dashboard
logStage "${StageRemark[5]}"
# [Docker]
docker compose -f /tmp/cloud-file-git/CentOS7_All_001/volume/tmp/dzctl/src/plugins/dz-docker/methods/apply/dz-dashboard-docker.ui/docker-compose.yml up -d
docker compose -f /tmp/cloud-file-git/CentOS7_All_001/volume/tmp/dzctl/src/plugins/dz-docker/methods/apply/dz-dashboard-portainer/docker-compose.yml up -d

# [Stage06] InstallTest | Install test for docker
logStage "${StageRemark[6]}"

# Other
echo ""
echo ""

[[ ! `docker images | grep joinsunsoft/docker.ui`  ]] && echo 1