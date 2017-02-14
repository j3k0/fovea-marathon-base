#!/bin/bash
#
# It happened that 2 instances of haproxy came up to run inside the container. In that case
# all collected haproxy stats are pretty messed up (with one or other other haproxy instance
# responding randomly).
#
# So this stat helps monitoring that million12/haproxy docker containers always have just
# 1 haproxy process running inside.
#
# More than 1 triggers a warning. Less than 1 trigger a critical alert.
#

MASTER_PROXY_CID=`docker ps|grep million12/haproxy:latest|awk '{ print $1 }'`
if [ "x$MASTER_PROXY_CID" = "x" ]; then exit 0; fi

MASTER_PROXY_NPROCESSES=`docker exec $MASTER_PROXY_CID ps xa|grep /usr/local/sbin/haproxy|wc -l`

echo "system.`hostname -s`.triominos.prod.master-proxy.nproc:$MASTER_PROXY_NPROCESSES|g"
