#!/bin/bash -i

echo '# Start dz' >>/root/.bashrc
echo 'alias dzalias="/root/.dz/dzalias.sh"' >>/root/.bashrc
echo 'alias dzcheck="/root/.dz/dzcheck.sh"' >>/root/.bashrc
echo 'alias dzfile="/root/.dz/dzfile.sh"' >>/root/.bashrc
echo 'alias dzfirewall="/root/.dz/dzfirewall.sh"' >>/root/.bashrc
echo 'alias dzhost="/root/.dz/dzhost.sh"' >>/root/.bashrc
echo 'alias dzreinit="/root/.dz/dzreinit.sh"' >>/root/.bashrc
echo 'alias dzset="/root/.dz/dzset.sh"' >>/root/.bashrc
echo 'alias dzsys="/root/.dz/dzsys.sh"' >>/root/.bashrc
echo 'alias dzyum="/root/.dz/dzyum.sh"' >>/root/.bashrc
echo '# End dz' >>/root/.bashrc
echo '' >>/root/.bashrc

source /root/.bashrc
