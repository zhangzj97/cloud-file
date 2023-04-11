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
sleep 10
tar -xvf /tmp/cloud-file.tar.gz
rm -fr /tmp/cloud-file
mv /tmp/cloud-file-$CloudFileVersion /tmp/cloud-file
# rm -f /tmp/cloud-file.tar.gz

# 触发别名功能
bash /tmp/cloud-file/CentOS7/001All/volume/tmp/dz-cloud-cli/src/dz-alias.sh

## 下载相应的版本
wget -t 20 -O /tmp/cloud-file.tar.gz https://github.com/zhangzj97/cloud-file/archive/refs/tags/v$CloudFileVersion.tar.gz
### TODO 存在异步问题
sleep 10
tar -xvf /tmp/cloud-file.tar.gz

if [[ ! -x /tmp/cloud-file-$CloudFileVersion ]]; then
    echo /tmp/cloud-file-$CloudFileVersion "No Exist"
fi

ll

rm -fr /tmp/cloud-file
mv /tmp/cloud-file-$CloudFileVersion /tmp/cloud-file
# rm -f /tmp/cloud-file.tar.gz

###########

# # Test
# ## 从 github 下载一个发行版本
# wget -t 20 -O /tmp/cloud-file.tar.gz https://github.com/xxxxx.tar.gz
# ## 解压
# tar -zxvf /tmp/cloud-file.tar.gz

# ### 加一个 目录存在的测试

# if [[ ! -x /tmp/cloud-file-$CloudFileVersion ]]; then
#     echo /tmp/cloud-file-$CloudFileVersion "No Exist"
# fi

# ## /tmp/cloud-file-1.1.1 => /tmp/cloud-file 去除文件夹上的版本号
# ### !!! 理论上 会有一个 /tmp/cloud-file-1.1.1 被解压出来
# ### !!! 但是 mv 报错 no such file or ...
# mv /tmp/cloud-file-$Version /tmp/cloud-file

# # 情况
# ## 如果 控制台直接执行 是可以的
# ## 但如果 是 bash xxx.sh 就会报错

# # 问
# ## 1. 是不是和异步相关 , tar 是异步的
# ### 实验了一下， tar 后 ， 目标文件夹（/tmp/cloud-file-1.1.1）不存在
