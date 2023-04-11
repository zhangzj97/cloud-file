#!/bin/bash -i

# 添加 Alias
## 清除 Alias
sed -i '/# <Dz> Alias/,/# <\/Dz> Alias/d' /etc/hosts
## 添加 Alias
echo '# <Dz> Alias' >>/root/.bashrc
echo 'alias dz=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-dispatch.sh' >>/root/.bashrc
echo 'alias dzalias=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-alias.sh' >>/root/.bashrc
echo 'alias dzhelp=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-help.sh' >>/root/.bashrc
echo 'alias dzcheck=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-check.sh' >>/root/.bashrc
echo 'alias dzfile=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-file.sh' >>/root/.bashrc
echo 'alias dzfirewall=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-firewall.sh' >>/root/.bashrc
echo 'alias dzhost=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-host.sh' >>/root/.bashrc
echo 'alias dzreinit=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-reinit.sh' >>/root/.bashrc
echo 'alias dzset=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-set.sh' >>/root/.bashrc
echo 'alias dzssl=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-ssl.sh' >>/root/.bashrc
echo 'alias dzsys=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-sys.sh' >>/root/.bashrc
echo 'alias dzyum=/tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-yum.sh' >>/root/.bashrc
echo '# </Dz> Alias' >>/root/.bashrc

## 永久保存
source /root/.bashrc
