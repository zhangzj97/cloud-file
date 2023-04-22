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
)

# Validate | Validate param
logStage "${StageRemark[1]}"
# [[ $* =~ get ]] && echo Error get && exit

# Certificate | Generate Certificate
logStage "${StageRemark[2]}"
# Generate a Certificate Authority Certificate
logStep "[Certificate] Config path"
mkdir /tmp/harbor-access
CaKeyPath=/tmp/harbor-access/ca.key
CaCrtPath=/tmp/harbor-access/ca.crt
logStep "[Certificate] Generate a Certificate Authority Certificate"
openssl genrsa -out $CaKeyPath 4096
openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top" -key $CaKeyPath -out $CaCrtPath
# Generate a Generate a Server Certificate
logStep "[Certificate] Generate a Generate a Server Certificate"
HarborKeyPath=/tmp/harbor-access/harbor.key
HarborCsrPath=/tmp/harbor-access/harbor.csr
HarborCrtPath=/tmp/harbor-access/harbor.crt
openssl genrsa -out $HarborKeyPath 4096
openssl req -sha512 -new -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top" -key $HarborKeyPath -out $HarborCsrPath
# Generate an x509 v3 extension file
logStep "[Certificate] Generate an x509 v3 extension file"
V3ExtPath=/tmp/harbor-access/v3.ext
/bin/cp -fa /tmp/cloud-file/CentOS7_All_001/volume/tmp/harbor/v3.ext $V3ExtPath
openssl x509 -req -sha512 -days 3650 -extfile $V3ExtPath -CA $CaCrtPath -CAkey $CaKeyPath -CAcreateserial -in $HarborCsrPath -out $HarborCrtPath

# InstallHarbor | Install harbor
# wget -O /tmp/harbor.installer.tgz https://kgithub.com/goharbor/harbor/releases/download/v2.8.0/harbor-offline-installer-v2.8.0.tgz --no-check-certificate
# wget -O /tmp/harbor.installer2.tgz https://kgithub.com/goharbor/harbor/releases/download/v2.8.0/harbor-online-installer-v2.8.0.tgz --no-check-certificate
if [[ ! -f /tmp/harbor.tgz ]]; then
  logErrorResult "Need /tmp/harbor.tgz"
fi
tar -xvf /tmp/harbor.tgz -C /tmp/ >/tmp/null
cp /tmp/harbor/harbor.yml.tmpl /tmp/harbor/harbor.yml
sed -i 's/hostname: reg.mydomain.com/hostname: 192.168.226.100' /tmp/harbor/harbor.yml
