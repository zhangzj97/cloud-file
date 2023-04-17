# 001All

## Step

### Release

```bash

# Download Install file
wget -O /bin/dzadm https://raw.fastgit.org/zhangzj97/cloud-file/main/CentOS7/001All/dzadm.sh --no-check-certificate | chmod u+x /bin/dzadm

dzadm

```

### Snipaste

```bash

sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts
curl -fsSL https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/001All/install.sh > /tmp/dzadm.sh
source /tmp/dz-install.sh 0.2.0

```

### Test

```bash

# kubectl create deployment nginx --image=nginx:1.14-alpine
kubectl create deployment nginxtest --image=nginx
kubectl expose deployment nginxtest --port=80 --type=NodePort
kubectl get pods,service



```
