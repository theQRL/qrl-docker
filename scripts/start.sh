#!/bin/sh
export USERNAME=$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)
mkdir -p /home/${USERNAME}

EASY_NAME=$(python3 /root/scripts/get_name.py)
echo "EasyName: ${EASY_NAME}"

VOLUME_NAME="/testnet_vols${EASY_NAME}"

cp /root/scripts/run_user.sh  /home/${USERNAME}/run_user.sh
mkdir -p ${VOLUME_NAME}
ln -s ${VOLUME_NAME} /home/${USERNAME}/.qrl

cp /root/scripts/config.yml  /home/${USERNAME}/.qrl/config.yml
cp /root/scripts/genesis.yml  /home/${USERNAME}/genesis.yml

chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
chown -R ${USERNAME}:${USERNAME} ${VOLUME_NAME}
chmod -R a+rwx /home/${USERNAME}

sudo BOOT_PHASE=${BOOT_PHASE} -i -u ${USERNAME} /home/${USERNAME}/run_user.sh
