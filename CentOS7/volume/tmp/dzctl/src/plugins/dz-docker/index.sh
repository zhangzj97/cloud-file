#!/bin/bash -i

# Validate
[[ $* =~ host ]] && echo Error dcoker : need action && exit

# Dispatch
MethodPath=$DZ_CLOUD_PATH/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins/dz-docker/methods
MethodCode=$1
[[ ! -f $MethodPath/$MethodCode/index.sh ]] && echo Error code1 && exit
source $MethodPath/$MethodCode/index.sh $MethodArgument
