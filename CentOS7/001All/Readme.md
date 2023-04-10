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
echo '# </Dz> GitHub' >>/etc/hosts

# Download package to /tmp/
# curl -fsSL https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/001All/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/001All/install.sh > /tmp/dz-install.sh
/tmp/dz-install.sh

# copy 重要文件
## Repo
cp -r /tmp/CentOS7/001All/volume/etc/yum.repos.d/* /etc/yum.repos.d/

## Docker volume

# 删除 package tar
rm -f /tmp/cloud-file.tar.gz

```

### Snipaste

```bash

```
