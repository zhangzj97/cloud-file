#!/bin/bash -i

# 清空 dz cli
sed -i "s/^# Start dz cli(*)# End dz cli/""/g" $ifcfgPath

# 添加
echo '# Start dz cli' >>/root/.bashrc
echo 'alias dz=/tmp/dz-clound-cli/src/dz-dispatch.sh' >>/root/.bashrc
echo 'alias dzalias="/tmp/dz-clound-cli/src/dz-alias.sh"' >>/root/.bashrc
echo 'alias dzhelp="/tmp/dz-clound-cli/src/dz-help.sh"' >>/root/.bashrc
echo 'alias dzcheck="/tmp/dz-clound-cli/src/dz-check.sh"' >>/root/.bashrc
echo 'alias dzfile="/tmp/dz-clound-cli/src/dz-file.sh"' >>/root/.bashrc
echo 'alias dzfirewall="/tmp/dz-clound-cli/src/dz-firewall.sh"' >>/root/.bashrc
echo 'alias dzhost="/tmp/dz-clound-cli/src/dz-host.sh"' >>/root/.bashrc
echo 'alias dzreinit="/tmp/dz-clound-cli/src/dz-reinit.sh"' >>/root/.bashrc
echo 'alias dzset="/tmp/dz-clound-cli/src/dz-set.sh"' >>/root/.bashrc
echo 'alias dzssl="/tmp/dz-clound-cli/src/dz-ssl.sh"' >>/root/.bashrc
echo 'alias dzsys="/tmp/dz-clound-cli/src/dz-sys.sh"' >>/root/.bashrc
echo 'alias dzyum="/tmp/dz-clound-cli/src/dz-yum.sh"' >>/root/.bashrc
echo '# End dz cli' >>/root/.bashrc
echo '' >>/root/.bashrc

source /root/.bashrc
