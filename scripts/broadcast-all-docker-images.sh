#!/bin/bash
set -e
INVENTORY="$1"
if [ -z $INVENTORY ]; then
    echo "usage: $0 <inventory-file>"
    exit 1
fi
curl -s https://raw.githubusercontent.com/j3k0/mesos-compose/master/compose | grep '^IMAGE_' > .mesos-images
. .mesos-images
rm -f .mesos-images

scripts/broadcast-docker-image.sh "$INVENTORY" jenserat/tinc
scripts/broadcast-docker-image.sh "$INVENTORY" "$IMAGE_ZOOKEEPER"
scripts/broadcast-docker-image.sh "$INVENTORY" "$IMAGE_MESOS"
scripts/broadcast-docker-image.sh "$INVENTORY" "$IMAGE_MARATHON"
scripts/broadcast-docker-image.sh "$INVENTORY" mesosphere/marathon-lb:v1.5.0
