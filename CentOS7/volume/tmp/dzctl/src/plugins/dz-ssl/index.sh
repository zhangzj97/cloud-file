#!/bin/bash -i

PluginCode=ssl

[[ $* =~ $PluginCode ]] && echo Error PluginCode && exit
MethodDirPath=$DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins/dz-$PluginCode/methods
MethodCode=$1
MethodIndexShPath=$MethodDirPath/$MethodCode/index.sh
[[ ! -f $MethodIndexShPath ]] && echo Error MethodCode && exit 0
source $MethodIndexShPath $MethodArgument
