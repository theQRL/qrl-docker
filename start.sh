#!/usr/bin/env bash

# Adjust this
LOCAL_QRL_DIR=${HOME}/.qrl


# Create and start the container
NODE_NAME=node1
mkdir -p ${LOCAL_QRL_DIR}
docker build -t qrl .
docker run -dt \
    --name ${NODE_NAME} \
    -p 127.0.0.1:8888:18888 \
    -p 127.0.0.1:2000:12000 \
    -p 127.0.0.1:8080:18080 \
    -v ${LOCAL_QRL_DIR}:/root/.qrl \
    qrl

# Experimental - Start 4 nodes
#docker run -dt --name node1  qrl
#docker run -dt --name node2  qrl
#docker run -dt --name node3  qrl
#docker run -dt --name node4  qrl
