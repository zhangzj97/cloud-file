#!/bin/bash -i

PluginCode=demo

MethodDirPath=$DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins/dz-$PluginCode/methods
MethodCode=$1
Argument=${*/$1/}
source $MethodDirPath/$MethodCode/index.sh $Argument
