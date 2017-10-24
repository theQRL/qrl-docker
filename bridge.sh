#!/bin/sh
docker exec -it qrldocker_node_1 ssh -R 9009:localhost:19009 ${USER}@172.19.0.1
