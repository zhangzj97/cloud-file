#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l domain:,port:,ssl:, -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --domain)
    DomainNew=$2 && shift 2
    ;;
  --port)
    PortNew=$2 && shift 2
    ;;
  --ssl)
    SSLNew=$2 && shift 2
    ;;
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!" && exit 1
    ;;
  esac
done
[[ ! $DomainNew ]] && logErrorResult "option --domain is invalid" && exit 0
[[ ! $PortNew ]] && logErrorResult "option --port is invalid" && exit 0

StageNo=1

logStage $StageNo "Install Harbor"
ServerDomainPort=$DomainNew:$PortNew
[[ $SSLNew ]] && ServerDomainPort=$SSLNew
DzCertsdPath=/etc/dz/certs.d
ServerCertsdPath=$DzCertsdPath/$ServerDomainPort
[[ ! -d $ServerCertsdPath ]] && logErrorResult "No $ServerCertsdPath" && exit
DzHarborYmlTmpl=$DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/dz/harbor-installer/dz-harbor.yml.tmpl
DzHarborYml=$DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/dz/harbor-installer/dz-harbor.yml
/bin/cp -fa $DzHarborYmlTmpl $DzHarborYml && logFile $DzHarborYml
sed -i "s/__hostname__/$DomainNew/" $DzHarborYml
sed -i "s/__https_port__/${PortNew}/" $DzHarborYml
sed -i "s#__https_certificate__#${ServerCertsdPath}/server.cert#" $DzHarborYml
sed -i "s#__https_private_key__#${ServerCertsdPath}/server.key#" $DzHarborYml
source $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/dz/harbor-installer/install.sh &&
  logStep "$DomainNew:$PortNew ==> "
