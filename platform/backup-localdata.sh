#!/bin/bash
set -e

BACKUP_ROOT=/mnt/data/backup/{{ cluster_name }}/{{ inventory_hostname }}

for DIR in /usr/local/{{ cluster_name }} /root/mesos-ggsp /root/mesos-ggsp-slave
do
  if [ -e "$DIR" ]; then
    mkdir -p $BACKUP_ROOT/$DIR
    ionice -c 3 -n 7 rsync -av --append --delete --bwlimit=512 --exclude '*.view' $DIR/ $BACKUP_ROOT/$DIR
  fi
done
