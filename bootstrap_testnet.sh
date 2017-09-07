#!/bin/sh
# Collect addresses
QRL_VARIANT=_boot1 docker-compose build; docker-compose up

# Get Addresses and prepare genesis block
python ./testnet/collect_wallets.py
QRL_VARIANT=_boot2 docker-compose build; docker-compose up
