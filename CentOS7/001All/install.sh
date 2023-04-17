#!/bin/bash -i

# Step 参数
StepMap=(
  AddDNS: "1"
)

logStep() {
  echo ===========================
  echo "[Step:" $StepMap[$1] "]"
  echo ===========================
}

logResult() {
  echo Successfully
}

# AddDNS | Add DNS host
logStep AddDNS
## [UpdateFile] Github DNS
sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts
## [Result]
logResult AddDNS

# AddRepo | Add some repo source
## [Install] epel
yum install -y -q epel-release
## [AddFile] repos
mv /tmp/cloud-file/CentOS7/001All/volume/etc/yum.repos.d/*.repo /etc/yum.repos.d/

# AddSoftware | Add some software
## [Install] wget
echo 检查 wget
[[ ! $(wget --version) ]] && yum install -y -q wget
## [Install] vim
echo 检查 wget
[[ ! $(vim --version) ]] && yum install -y -q vim
## [Install] jq
echo 检查 jq
[[ ! $(jq --version) ]] && yum install -y -q jq
## [Result]
logResult AddDNS

#
