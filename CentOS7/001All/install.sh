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
WgetVersion = rpm -qa wget
if [[ ! WgetVersion =~ 'wget' ]]; then
    echo WgetVersion
    yum install -y wget
fi

## 安装 vim
VimtVersion = rpm -qa vim
if [[ ! VimVersion =~ 'vim' ]]; then
    echo VimVersion
    yum install -y vim
fi

# 安装 CloudFile
## 获取版本号
CloudFileVersion = $1

## 检查版本号
if [[ !$CloudFileVersion || !$ipAddrNew =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "请输入 版本号"
    exit
fi

## 下载相应的版本
curl -fsSL https://github.com/zhangzj97/cloud-file/archive/refs/tags/v$CloudFileVersion.tar.gz >/tmp/cloud-file.tar.gz
tar -zxvf /tmp/cloud-file.tar.gz
mv /tmp/cloud-file-$CloudFileVersion /tmp/cloud-file