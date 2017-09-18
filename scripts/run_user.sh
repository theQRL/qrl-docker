#!/bin/sh

# Common
rm -rf ${HOME}/QRL

# Enable this once we deploy through pip packages
#RUN pip install -i https://testpypi.python.org/pypi --extra-index-url https://pypi.python.org/simple/  --upgrade qrl

REPO=https://github.com/jleni/QRL.git
REPO_BRANCH=testnet
git clone -b ${REPO_BRANCH} ${REPO} ${HOME}/QRL
GITHASH=$(git -C ${HOME}/QRL/ rev-parse HEAD)
#echo "GitRepo: " $GITHASH

# pip3 install -r ${HOME}/QRL/requirements.txt

case "${BOOT_PHASE}" in
        bootstrap)
            echo "Collect Wallets"
            python3 ${HOME}/QRL/start_qrl.py -q --get-wallets > ${HOME}/.qrl/wallet_address
            ;;
         
        start)
            echo "Start Nodes"

            # # qrl binds to 127.0.0.1 so we need some special redirection here
            # socat -d tcp-listen:18888,reuseaddr,fork tcp:127.0.0.1:8888 &
            # socat -d tcp-listen:12000,reuseaddr,fork tcp:127.0.0.1:2000 &
            # socat -d tcp-listen:18080,reuseaddr,fork tcp:127.0.0.1:8080 &

            cp ${HOME}/genesis.yml ${HOME}/QRL/qrl/core/genesis.yml
            python3 ${HOME}/QRL/start_qrl.py
            ;;
        *)
            echo $"Usage: $0 {bootstrap|start}"
            exit 1
esac
