#!/bin/bash -i

PluginCode=k8s

MethodDirPath=$DZ_CTL_PATH/src/plugins/dz-$PluginCode/methods
MethodCode=$1
Argument=${*/$1/}
source $MethodDirPath/$MethodCode/index.sh ArgHolder $Argument
