#!/bin/bash
cat /proc/stat | grep '^cpu ' | awk '{ printf "PREFIX.%s.user:%s|g\nPREFIX.%s.nice:%s|g\nPREFIX.%s.system:%s|g\nPREFIX.%s.idle:%s|g\nPREFIX.%s.iowait:%s|g\n", $1,$2,$1,$3,$1,$4,$1,$5,$1,$6 }' | sed "s/PREFIX/system.`hostname -s`.stat/g"
