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

StageNo=0

logStage $StageNo "Install Harbor"
ServerDomainPort=$DomainNew:$PortNew
[[ $SSLNew ]] && ServerDomainPort=$SSLNew
DzCertsdPath=/etc/dz/certs.d
ServerCertsdPath=$DzCertsdPath/$ServerDomainPort
[[ ! -d $ServerCertsdPath ]] && logErrorResult "No $ServerCertsdPath" && exit
/bin/cp -fa /etc/dz/harbor-installer/dz-harbor.yml.tmpl /etc/dz/harbor-installer/dz-harbor.yml
sed -i "s/{ hostname }/${domain}" /etc/dz/harbor-installer/dz-harbor.yml
sed -i "s/{ port }/${port}" /etc/dz/harbor-installer/dz-harbor.yml
sed -i "s/{ https_certificate }/${ServerCertsdPath}/server.cert" /etc/dz/harbor-installer/dz-harbor.yml
sed -i "s/{ https_private_key }/${ServerCertsdPath}/server.key" /etc/dz/harbor-installer/dz-harbor.yml
source /etc/dz/harbor-installer/install.sh
