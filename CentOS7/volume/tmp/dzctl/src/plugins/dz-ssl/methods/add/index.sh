#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l domain:,port: -n 'dzctl' -- "$@")
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
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit
    ;;
  esac
done
[[ ! $DomainNew ]] && dzLogError "option --domain is invalid" && exit
[[ ! $PortNew ]] && dzLogError "option --port is invalid" && exit

StageNo=0

logStage $StageNo "Certificate Authority"
ServerDomainPort=$DomainNew:$PortNew
DzCertsdPath=/etc/dz/certs.d
ServerCertsdPath=$DzCertsdPath/$ServerDomainPort
CaKeyPath=$DzCertsdPath/ca.key
CaCrtPath=$DzCertsdPath/ca.crt
if [[ ! -f $CaKeyPath ]]; then
  logStep "[Certificate] Generate CA Certificate"
  mkdir -p $DzCertsdPath && logDir $DzCertsdPath
  CaSubj="/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top"
  openssl genrsa -out $CaKeyPath 4096 && logFile $CaKeyPath
  openssl req -x509 -new -nodes -sha512 -days 3650 -subj $CaSubj -key $CaKeyPath -out $CaCrtPath && logFile $CaCrtPath
fi
let StageNo+=1

logStage $StageNo "Generate a Server Certificate"
ServerKeyPath=$ServerCertsdPath/server.key
ServerCsrPath=$ServerCertsdPath/server.csr
ServerCrtPath=$ServerCertsdPath/server.crt
ServerCertPath=$ServerCertsdPath/server.cert
[[ -f $ServerKeyPath ]] && logErrorResult "Doamin exists" && exit 0
logStep "[Certificate] Generate Server key"
mkdir -p $ServerCertsdPath && logDir $ServerCertsdPath
ServerSubj="/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top"
openssl genrsa -out $ServerKeyPath 4096 && logFile $ServerKeyPath
openssl req -sha512 -new -subj $ServerSubj -key $ServerKeyPath -out $ServerCsrPath && logFile $ServerCsrPath
# Generate an x509 v3 extension file
logStep "[Certificate] Generate an x509 v3 extension file"
V3ExtPath=$ServerCertsdPath/v3.ext
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/dz/certs.d/v3.ext $V3ExtPath && logFile $V3ExtPath
openssl x509 -req -sha512 -days 3650 -extfile $V3ExtPath -CA $CaCrtPath -CAkey $CaKeyPath -CAcreateserial -in $ServerCsrPath -out $ServerCrtPath && logFile $ServerCrtPath
openssl x509 -inform PEM -in $ServerCrtPath -out $ServerCertPath && logFile $ServerCertPath
cpDir $DzCertsdPath/$ServerDomainPort /etc/docker/certs.d/$ServerDomainPort && logDir /etc/docker/certs.d/$ServerDomainPort
let StageNo+=1

logStage $StageNo "Restart Service"
DockerRestartFlag=1
[[ $DockerRestartFlag ]] && systemctl restart docker
