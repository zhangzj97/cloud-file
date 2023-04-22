#!/bin/bash -i

PluginDirPath=$DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins
PluginCode=$1
MethodCode=$2
Argument=${*/$1/}
[[ ! -f $PluginDirPath/dz-$PluginCode/index.sh ]] && echo Error PluginCode && exit
[[ ! -f $PluginDirPath/dz-$PluginCode/methods/$MethodCode/index.sh ]] && echo Error MethodCode && exit
source $PluginDirPath/dz-$PluginCode/index.sh $Argument
