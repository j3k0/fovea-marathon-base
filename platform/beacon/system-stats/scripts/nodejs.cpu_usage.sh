#!/bin/bash
#
# On rare occurance, a nodejs process gets stucked in a system call.
#
# This log appears in `dmesg`
# "dirperm1 breaks the protection by the permission bits on the lower branch"
#
# https://github.com/docker/docker/issues/21081 seems to indicate it is a kernel bug
#
# Monitoring CPU usage of node processes should trigger a warning when they stay at a stable 100%
#
ps aux | grep "[ /]node " | grep -v grep | awk '{ sum += $3 } END { printf "system.HOSTNAME.nodejs.cpu_usage:%d|g\n", sum }' | sed "s/HOSTNAME/`hostname -s`/"
