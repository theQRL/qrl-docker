# QRL container (docker / docker compose)

These scripts allow for running one or many containerized qrl nodes.

Using docker-compose you can run many in parallel or even your local testnet.

## Installing Docker CE

Follow the corresponding instructions:

|   |   |
|---|---|
|Windows | https://docs.docker.com/docker-for-windows/install/   |
|Linux   | https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/ |
|OSX     | https://docs.docker.com/docker-for-mac/install/ | 
|||

Install docker compose

`pip install docker-compose`

## Getting QRL Docker scripts

Get the docker scripts running this:

```
git clone https://github.com/jleni/qrl_docker`
cd qrl_docker
```

## Getting latest and running

```
docker-compose build; docker-compose up
```

to stop:
```
docker-compose down
```

# I want more details! :)

## Custom Configuration (optional)

The configuration file for docker-compose is `docker-compose.yml`

At the moment, it will create a few nodes that will run in parallel. Fortunately the file format is quite descriptive and you can find lots of information online.

Each node will get the wallet from a corresponding ./volumes/node???/.qrl

## Running in attached mode

```
docker-compose up
```

The first time it will take a little longer as everything has to be downloaded. After that things will be much faster.

## Running in daemonized mode

```
docker-compose up -d
```

## Watching logs from nodes

When running in daemon node, you may want to see what is going on

```
docker-compose logs
```

## Check the overall status

```
docker-compose ps
```

## Attach to some node

```
docker exec -it qrldocker_node1_1 /bin/bash
```

replace `qrldocker_node1_1` with the node name. You can get them all with `docker-compose ps`

## Shut everything down

```
docker-compose down
```

## Flushing / cleaning everything

**Flush will remove everything !!!! Be careful if you have other containers** !!!
