# 001All

## Step

### Release

```bash

# Download Install file
yum instal wget
wget -O /tmp/dzinit.sh https://raw.fastgit.org/zhangzj97/cloud-file/main/CentOS7/volume/tmp/dzadm/index.sh --no-check-certificate | chmod u+x /tmp/dzinit.sh | ln -fs /tmp/dzinit.sh /bin/dzinit


curl -fsSL https://raw.fastgit.org/zhangzj97/cloud-file/main/CentOS7/volume/tmp/dzadm/index.sh > /tmp/dzinit.sh
curl -fsSL https://raw.fastgit.org/zhangzj97/cloud-file/main/CentOS7/volume/tmp/dzadm/index.sh > /tmp/dzinit.sh | chmod u+x /tmp/dzinit.sh | ln -fs /tmp/dzinit.sh /bin/dzinit
curl -fsSL https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/volume/tmp/dzadm/index.sh > /tmp/dzinit.sh | chmod u+x /tmp/dzinit.sh | ln -fs /tmp/dzinit.sh /bin/dzinit

source dzinit /demopath

```

### Snipaste

```bash

sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts
curl -fsSL https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/volume/tmp/dzadm/index.sh > /tmp/dzadm.sh
source /tmp/dz-install.sh 0.2.0

```

### Test

```bash

# kubectl create deployment nginx --image=nginx:1.14-alpine
kubectl create deployment nginxtest --image=nginx
kubectl expose deployment nginxtest --port=80 --type=NodePort
kubectl get pods,service



```
