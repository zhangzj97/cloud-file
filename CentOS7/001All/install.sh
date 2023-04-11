#!/bin/bash -i

# 添加 DNS
## 清除 Github DNS
sed -i '/# <Dz> GitHub/,/# <\/Dz> GitHub/d' /etc/hosts
## 添加 Github DNS
echo '# <Dz> GitHub' >>/etc/hosts
echo '185.199.110.133 raw.githubusercontent.com' >>/etc/hosts
echo '140.82.113.3    raw.github.com' >>/etc/hosts
echo '# </Dz> GitHub' >>/etc/hosts

# 安装重要软件
## 安装 wget
WgetVersion=$(rpm -qa wget)
if [[ ! $WgetVersion =~ 'wget' ]]; then
    yum install -y wget
fi

## 安装 vim
### TODO 如何判断 vim 是否已经安装
VimtVersion=$(rpm -qa vim)
if [[ ! $VimVersion =~ 'vim' ]]; then
    yum install -y vim
fi

# 安装 CloudFile
## 获取版本号
CloudFileVersion=$1
echo $CloudFileVersion

## 检查版本号
if [[ ! $CloudFileVersion || ! $CloudFileVersion =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "请输入 版本号"
    exit
fi

## 下载相应的版本
wget -t 20 -O /tmp/cloud-file.tar.gz https://github.com/zhangzj97/cloud-file/archive/refs/tags/v$CloudFileVersion.tar.gz
### TODO 存在异步问题
tar -zxvf /tmp/cloud-file.tar.gz
rm -fr /tmp/cloud-file
mv /tmp/cloud-file-$CloudFileVersion /tmp/cloud-file
# rm -f /tmp/cloud-file.tar.gz

# 触发别名功能
bash /tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-alias.sh

# tar -zxvf /tmp/cloud-file.tar.gz
# rm -fr /tmp/cloud-file
# mv /tmp/cloud-file-0.1.2 /tmp/cloud-file
