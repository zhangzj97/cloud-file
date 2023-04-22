#!/bin/bash -i

# Validate
[[ $* =~ harbor ]] && echo Error dcoker : need action && exit

# Dispatch
MethodPath=$DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins/dz-harbor/methods
MethodCode=$1
[[ ! -f $MethodPath/$MethodCode/index.sh ]] && echo Error code && exit
source $MethodPath/$MethodCode/index.sh $MethodArgument
