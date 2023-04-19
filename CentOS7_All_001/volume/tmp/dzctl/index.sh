#!/bin/bash -i

# Dispatch
PluginPath=/tmp/dzctl/src/plugins
PluginCode=$1
PluginArgument=${*/$1/}
[[ ! -f $PluginPath/dz-$PluginCode/index.sh ]] && echo Error plugin && exit
source $PluginPath/dz-$PluginCode/index.sh $PluginArgument

# case $PluginCode in
# host)
#   ;;
# docker)
#   source $PluginPath/dz-docker/index.sh $PluginArgument
#   ;;
# jenkins)
#   source $PluginPath/dz-jenkins/index.sh $PluginArgument
#   ;;
# harbor)
#   source $PluginPath/dz-harbor/index.sh $PluginArgument
#   ;;
# nginx)
#   source $PluginPath/dz-nginx/index.sh $PluginArgument
#   ;;
# nacos)
#   source $PluginPath/dz-nacos/index.sh $PluginArgument
#   ;;
# nexus)
#   source $PluginPath/dz-nexus/index.sh $PluginArgument
#   ;;
# k8s)
#   source $PluginPath/dz-k8s/index.sh $PluginArgument
#   ;;
# k3s)
#   source $PluginPath/dz-k3s/index.sh $PluginArgument
#   ;;
# rancher)
#   source $PluginPath/dz-rancher/index.sh $PluginArgument
#   ;;
# mysql80)
#   source $PluginPath/dz-mysql80/index.sh $PluginArgument
#   ;;
# mysql56)
#   source $PluginPath/dz-mysql56/index.sh $PluginArgument
#   ;;
# mysql57)
#   source $PluginPath/dz-mysql57/index.sh $PluginArgument
#   ;;
# zookeeper)
#   source $PluginPath/dz-zookeeper/index.sh $PluginArgument
#   ;;
# nodejs)
#   source $PluginPath/dz-nodejs/index.sh $PluginArgument
#   ;;
# redis)
#   source $PluginPath/dz-redis/index.sh $PluginArgument
#   ;;
# mongdb)
#   source $PluginPath/dz-mongdb/index.sh $PluginArgument
#   ;;
# tomcat)
#   source $PluginPath/dz-tomcat/index.sh $PluginArgument
#   ;;
# springboot)
#   source $PluginPath/dz-springboot/index.sh $PluginArgument
#   ;;
# *)
#   echo 'Error : No plugin code'
#   ;;
# esac
