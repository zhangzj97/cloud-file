# 001All

## Step

```bash

# Download package to /tmp/
curl -o https://github.com/zhangzj97/cloud-file/archive/refs/tags/v0.1.0.tar.gz /tmp/cloud-file.tar.gz

# 解压
tar -zxvf /tmp/cloud-file.tar.gz

# copy 重要文件
## Repo
cp -r /tmp/CentOS7/001All/volume/etc/yum.repos.d/* /etc/yum.repos.d/

## Docker volume

# 删除 package tar
rm -f /tmp/cloud-file.tar.gz

```
