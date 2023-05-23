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
if [[ ! $Domain ]]; then
	IfcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
	dzTmpFsPush $IfcfgPath &&
		StaticIp=$(dzTmpFsMatch $IfcfgPath 's|^.*IPADDR="?([^"]*)"?.*$|\1|g')
	Domain=$StaticIp
fi
# [[ ! $Port ]] && dzLogError "option --port is invalid" && exit 0

###################################################################################################
## 备份
###################################################################################################

BackupServer() {
	Service=$1

	dzLogInfo "备份 => ${Service}"

	dzTarC $ServerPath/backup/dz-$Service-$TimeFlag.bak.tar.gz $ServerPath/dz-$Service
}

###################################################################################################
## 业务
###################################################################################################
StageNo=1

# TODO
ServerPath=/etc/dz-server
DokcerPath=/etc/docker

dzLogStage $StageNo "备份 SSL"
TimeFlag=$(date "+%Y-%m-%d_%H-%M-%S")
mkdir -p /etc/dz-server/backup/.tmp
dzTarC $ServerPath/backup/docker-$TimeFlag.bak.tar.gz $DokcerPath
dzLogStage $StageNo "备份 Server"
BackupServer docker-cli
BackupServer docker-web
BackupServer harbor
BackupServer jenkins
BackupServer rancher
BackupServer gitlab
docker exec -it dz-gitlab gitlab-backup create
dzLogInfo "备份 => gitlab"
LasteGitlabFilename=$(ls -t /etc/dz-server/dz-gitlab/volume/data/backups/ | head -n1)
/bin/cp -fa $ServerPath/dz-gitlab/volume/data/backups/$LasteGitlabFilename /etc/dz-server/backup/.tmp.gitlab
/bin/cp -fa $ServerPath/dz-gitlab/volume/config/gitlab.rb /etc/dz-server/backup/.tmp.gitlab
/bin/cp -fa $ServerPath/dz-gitlab/volume/config/gitlab-secrets.json /etc/dz-server/backup/.tmp.gitlab
tar -czvPf $ServerPath/backup/dz-gitlab-$TimeFlag.bak.tar.gz -C /etc/dz-server/backup/.tmp.gitlab/ .
rm -rf /etc/dz-server/backup/.tmp.gitlab/
dzLogInfo "备份 => server"
/bin/cp -fa /etc/dz-server/backup/*-$TimeFlag.bak.tar.gz /etc/dz-server/backup/.tmp/
tar -czvPf $ServerPath/backup/server-$TimeFlag.bak.tar.gz -C /etc/dz-server/backup/.tmp/ .
rm -rf /etc/dz-server/backup/.tmp/
let StageNo+=1

sz $ServerPath/backup/server-$TimeFlag.bak.tar.gz
