#!/bin/sh

export DOCKER_UID=$( id -u ${USER} )
export DOCKER_GID=$( id -g ${USER} )
export NUM_NODES=5

echo "****************************************************************"
echo "****************************************************************"
echo "                       STARTING LOCALNET"
echo "****************************************************************"
echo "****************************************************************"
export BOOT_PHASE=start
docker-compose up --scale node=${NUM_NODES}
