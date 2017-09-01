#!/usr/bin/env bash
NODE_NAME=node1
docker exec -i -t ${NODE_NAME} /bin/bash

# if [ $# -lt 1 ]; then
#   echo 1>&2 "$0: not enough arguments"
#   exit 2
# fi
# docker exec -i -t ${1} /bin/bash
