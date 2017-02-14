#!/bin/bash

STORAGE_BOX=/srv/{{ storage_box.host }}
BACKUP_ROOT=/mnt/backup-to-storagebox

set +e
umount $STORAGE_BOX
umount $BACKUP_ROOT

set -e
echo "mounting $STORAGE_BOX"
mount $STORAGE_BOX
echo "mounting $BACKUP_ROOT"
mount $BACKUP_ROOT


for DIR in /etc /usr/local/{{ cluster_name }} /root
do
    if [ -e "$DIR" ]; then
        mkdir -p $BACKUP_ROOT/$DIR
        ionice -c 3 -n 7 rsync -av --append --delete --progress --exclude '*.view' $DIR/ $BACKUP_ROOT/$DIR
    fi
done

umount $BACKUP_ROOT
umount $STORAGE_BOX
