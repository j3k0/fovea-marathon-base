#!/bin/bash
#
# Let's store the docker containers running on a host at any given time.
#
timeout 5 docker ps | grep -v 'IMAGE' | wc -l | awk '{ printf "system.HOSTNAME.docker.containers.count:%d|g\n", $1 }' | sed "s/HOSTNAME/`hostname -s`/"
