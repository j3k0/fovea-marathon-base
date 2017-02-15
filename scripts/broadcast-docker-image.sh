#!/bin/bash
set -e
REGISTRY="${REGISTRY:-docker-registry.local:5000}"
INVENTORY="$1"
IMAGE="$2"
if [ -z $IMAGE ]; then
    echo "usage: $0 <inventory-file> <docker-image>"
    exit 1
fi
if curl http://$REGISTRY; then
    echo "Using docker registry '$REGISTRY'"
else
    echo "Make sure docker registry '$REGISTRY' exists and is accessible from all hosts."
    exit 1
fi
TEMP_IMAGE=temporary-$RANDOM
set -o xtrace
docker pull $IMAGE
docker tag $IMAGE $REGISTRY/$TEMP_IMAGE
docker push $REGISTRY/$TEMP_IMAGE
ansible all -i "$INVENTORY" -a "docker pull $REGISTRY/$TEMP_IMAGE"
docker rmi $REGISTRY/$TEMP_IMAGE
ansible all -i "$INVENTORY" -a "docker tag $REGISTRY/$TEMP_IMAGE $IMAGE"
ansible all -i "$INVENTORY" -a "docker rmi $REGISTRY/$TEMP_IMAGE"
