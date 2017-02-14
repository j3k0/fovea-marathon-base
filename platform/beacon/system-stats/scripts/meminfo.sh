#!/bin/bash
used_free=`free|grep -- '-/+ buffers/cache'|cut -d: -f2`
if [[ ! -z $used_free ]]; then
echo $used_free|awk '{ printf "PREFIX.used:%s|g\nPREFIX.free:%s|g\n", $1,$2 }' | sed "s/PREFIX/system.`hostname -s`.meminfo/g"
fi
