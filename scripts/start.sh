#!/bin/sh
export USERNAME=$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)
mkdir -p /home/${USERNAME}
mkdir -p /testnet_vols/${HOSTNAME}

cp /root/scripts/run_user.sh  /home/${USERNAME}/run_user.sh
ln -s /testnet_vols/${HOSTNAME} /home/${USERNAME}/.qrl

cp /root/scripts/config.yaml  /home/${USERNAME}/.qrl/config.yaml
cp /root/scripts/genesis.yml  /home/${USERNAME}/genesis.yml


chown -R ${USERNAME} /home/${USERNAME}
chown -R ${USERNAME} /testnet_vols/${HOSTNAME}

sudo BOOT_PHASE=${BOOT_PHASE} -i -u ${USERNAME} /home/${USERNAME}/run_user.sh
