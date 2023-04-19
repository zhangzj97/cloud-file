#!/bin/bash -i

# Validate
[[ $* =~ host ]] && echo Error host && exit

# Dispatch
MethodPath=/tmp/dzctl/src/plugins/dz-host/methods
MethodCode=$1
[[ ! -f $MethodPath/$MethodCode/index.sh ]] && echo Error code && exit
source $MethodPath/$MethodCode/index.sh $MethodArgument
