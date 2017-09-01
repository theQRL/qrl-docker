#!/usr/bin/env bash
docker stop node1
docker rm node1

# Stop all nodes
#docker stop $(docker ps -a -q)
#docker rm $(docker ps -a -q)

