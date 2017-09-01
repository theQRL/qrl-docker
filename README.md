# QRL container (docker)

## Installing Docker CE

Follow the corresponding instructions:

|   |   |
|---|---|
|Windows | https://docs.docker.com/docker-for-windows/install/   |
|Linux   | https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/ |
|OSX     | https://docs.docker.com/docker-for-mac/install/ | 
|||

## Getting QRL Docker scripts

Get the docker scripts running this:

`git clone https://github.com/jleni/qrl_docker`

`cd qrl_docker`

## Custom Configuration (optional)

By default, data will be kept in `${HOME}/.qrl` in your host.

If you want to keep your persistent data in a different place, assign a diferent directory to `LOCAL_QRL_DIR` inside `qrl_docker/start.sh`

## Start the container

Run `./start.sh`

The first time it will take a little longer as everything has to be downloaded. After that things will be much faster. 

## Stop the container

Run `./stop.sh`

## Attach to the container

Run `./connect.sh`

At the moment, the scripts start the container as `node1`. If you feel adventurous, you can modify and run several containers at the same time, etc.

## Flushing / cleaning everything

**Flush will remove everything !!!! Be careful if you have other containers** !!!
