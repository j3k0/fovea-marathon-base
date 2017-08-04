#!/bin/bash

#
# CollectD - Docker
#
# This script will collect cpu/memory stats on running docker containers using cgroup
# and output the data in a collectd-exec plugin friendly format.
#
# Author: Mike Moulton (mike@meltmedia.com)
# License: MIT
#

# Location of the cgroup mount point, adjust for your system
CGROUP_MOUNT="/sys/fs/cgroup"

DOCKERCONTAINERS_PATH="/var/lib/docker/containers"

HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

inspect ()
{
  docker inspect $1 | sed 's/^\[//g' | sed 's/^\]//g'
}

inspect_env ()
{
  inspect $1 | jq -r .Config.Env | grep -w $2 | cut -d\" -f2 | cut -d= -f2
}

inspect_image ()
{
  inspect $1 | jq -r .Config.Image
}

collect ()
{
  cd -- "$1"
  FULLNAME="$1"

  # If the directory length is 64, it's likely a docker instance
  LENGTH=$(expr length $FULLNAME)
  if [ "$LENGTH" -eq "64" ]; then

    # Shorten the name to 12 for brevity, like docker does
    NAME=$(expr substr $FULLNAME 1 12)

    # Retrieve and cleanup image name
    IMAGE=$(inspect_image $FULLNAME | sed 's/[\/.-]/_/g' | sed 's/:/./' )

    # Retrieve marathon app id (if any)
    # Peplace '/' with '.' should work well with PreserveSeparator
    APP_ID=$(inspect_env $FULLNAME MARATHON_APP_ID | sed 's/[:.-]/_/g' | sed 's/^\///' | sed 's/\//./g')

    if [ -z $APP_ID ]; then
      APP_NAME=docker-image.${IMAGE}.$NAME
    else
      APP_NAME=docker-marathon.${APP_ID}.$NAME
    fi

    # If we are in a cpuacct cgroup, we can collect cpu usage stats
    if [ -e cpuacct.stat ]; then
        USER=$(cat cpuacct.stat | grep '^user' | awk '{ print $2; }');
        SYSTEM=$(cat cpuacct.stat | grep '^system' | awk '{ print $2; }');
        echo "PUTVAL \"$HOSTNAME/$APP_NAME/cpu-user\" interval=$INTERVAL N:$USER"
        echo "PUTVAL \"$HOSTNAME/$APP_NAME/cpu-system\" interval=$INTERVAL N:$SYSTEM"
    fi;

    # If we are in a memory cgroup, we can collect memory usage stats
    if [ -e memory.stat ]; then
        CACHE=$(cat memory.stat | grep -w '^cache' | awk '{ print $2; }');
        RSS=$(cat memory.stat | grep -w '^rss' | awk '{ print $2; }');
        echo "PUTVAL \"$HOSTNAME/$APP_NAME/memory-cached\" interval=$INTERVAL N:$CACHE"
        echo "PUTVAL \"$HOSTNAME/$APP_NAME/memory-used\" interval=$INTERVAL N:$RSS"
    fi;

    # If we are in a blkio cgroup, we can collect block io usage stats
    if [ -e blkio.throttle.io_serviced ]; then
        # Extracting those are more complex than this, as there can be multiple block devices...
        # So, I'll go with total for now...
        # READ=$(cat blkio.throttle.io_serviced  | grep -w ' Read '  | awk '{ print $3; }');
        # WRITE=$(cat blkio.throttle.io_serviced | grep -w ' Write ' | awk '{ print $3; }');
        # SYNC=$(cat blkio.throttle.io_serviced  | grep -w ' Sync '  | awk '{ print $3; }');
        # ASYNC=$(cat blkio.throttle.io_serviced | grep -w ' Async ' | awk '{ print $3; }');
        # echo "PUTVAL \"$HOSTNAME/$APP_NAME/blkio-read\" interval=$INTERVAL N:$READ"
        # echo "PUTVAL \"$HOSTNAME/$APP_NAME/blkio-write\" interval=$INTERVAL N:$WRITE"
        # echo "PUTVAL \"$HOSTNAME/$APP_NAME/blkio-sync\" interval=$INTERVAL N:$SYNC"
        # echo "PUTVAL \"$HOSTNAME/$APP_NAME/blkio-async\" interval=$INTERVAL N:$ASYNC"
        TOTAL=$(cat blkio.throttle.io_serviced  | grep -w '^Total' | awk '{ print $2; }');
        echo "PUTVAL \"$HOSTNAME/$APP_NAME/disk_ops_complex-total\" interval=$INTERVAL N:$TOTAL"
        TOTAL=$(cat blkio.throttle.io_service_bytes | grep -w '^Total'  | awk '{ print $2; }');
        echo "PUTVAL \"$HOSTNAME/$APP_NAME/disk_ops_complex-bytes\" interval=$INTERVAL N:$TOTAL"
    fi;

  fi;

  # Iterate over all sub directories
  for d in *
  do
    if [ -d "$d" ]; then
      ( collect "$d" )
    fi;
  done
}

while sleep "$INTERVAL"; do
  # Collect stats on memory usage
  ( collect "$CGROUP_MOUNT/memory" )

  # Collect stats on cpu usage
  ( collect "$CGROUP_MOUNT/cpuacct" )

  # Collect stats on blkio usage
  ( collect "$CGROUP_MOUNT/blkio" )
done
