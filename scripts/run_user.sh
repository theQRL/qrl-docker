#!/bin/sh

REPO=https://github.com/jleni/QRL.git
REPO_BRANCH=master
#RUN pip install -i https://testpypi.python.org/pypi --extra-index-url https://pypi.python.org/simple/  --upgrade qrl

# Common
rm -rf ${HOME}/QRL

git clone -b ${REPO_BRANCH} ${REPO} ${HOME}/QRL
GITHASH=$(git -C ${HOME}/QRL/ rev-parse HEAD)
echo "GitRepo: " $GITHASH

echo "Install dependencies"
sudo -H pip3 install -r ${HOME}/QRL/requirements.txt #> /dev/null

ifconfig | perl -nle 's/dr:(\S+)/print $1/e'

echo "Boot phase: ${BOOT_PHASE}"
case "${BOOT_PHASE}" in
        bootstrap)
            echo "Collect Wallets"
            python3 ${HOME}/QRL/start_qrl.py -q --get-wallets > ${HOME}/.qrl/wallet_address
            ;;
         
        start)
            if [ "$EASYNAME" != "/qrldocker_node_1" ]
            then
                echo "Waiting for node 1"
                sleep 1
            else
                # qrl binds to 127.0.0.1 so we need some special redirection here
                socat -d tcp-listen:18888,reuseaddr,fork tcp:127.0.0.1:8888 &
                socat -d tcp-listen:12000,reuseaddr,fork tcp:127.0.0.1:2000 &
                socat -d tcp-listen:18080,reuseaddr,fork tcp:127.0.0.1:8080 &
                socat -d tcp-listen:19009,reuseaddr,fork tcp:127.0.0.1:9009 &
            fi

            cp ${HOME}/genesis.yml ${HOME}/QRL/qrl/core/genesis.yml
            python3 ${HOME}/QRL/start_qrl.py -l DEBUG
            ;;
        *)
            echo $"Usage: $0 {bootstrap|start}"
            exit 1
esac
