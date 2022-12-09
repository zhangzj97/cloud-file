#!/bin/bash -i

echo '# Start dz' >>/root/.bashrc
echo 'alias dzcheck="/root/.dz/dzcheck.sh"' >>/root/.bashrc
echo 'alias dzset="/root/.dz/dzset.sh"' >>/root/.bashrc
echo 'alias dzsys="/root/.dz/dzsys.sh"' >>/root/.bashrc
echo 'alias dzinit="/root/.dz/dzinit.sh"' >>/root/.bashrc
echo '# End dz' >>/root/.bashrc
echo '' >>/root/.bashrc

source /root/.bashrc
