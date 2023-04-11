# 001All

## Step

### Release

```bash

# 添加 DNS
## 清除 Github DNS
sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
## 添加 Github DNS
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts

# Download Install file
curl -fsSL https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/001All/install.sh > /tmp/dz-install.sh
source /tmp/dz-install.sh 0.1.3

```

### Snipaste

```bash


sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '140.82.112.4    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts
curl -fsSL https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/001All/install.sh > /tmp/dz-install.sh
source /tmp/dz-install.sh 0.1.3






```
