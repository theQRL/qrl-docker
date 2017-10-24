#!/bin/sh
export USERNAME=$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)
mkdir -p /home/${USERNAME}

EASYNAME=$(python3 /root/scripts/get_name.py)
echo "EasyName: ${EASYNAME}"

VOLUME_NAME="/volumes${EASYNAME}"

cp /root/scripts/run_user.sh  /home/${USERNAME}/run_user.sh
mkdir -p ${VOLUME_NAME}
ln -s ${VOLUME_NAME} /home/${USERNAME}/.qrl

if [ -n "${LOCALNET_ONLY:+1}" ]; then
    cp /root/scripts/config.yml  /home/${USERNAME}/.qrl/config.yml
    cp /root/scripts/genesis.yml  /home/${USERNAME}/genesis.yml
fi

chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
chown -R ${USERNAME}:${USERNAME} ${VOLUME_NAME}
chmod -R a+rwx /home/${USERNAME}

sudo BOOT_PHASE=${BOOT_PHASE} EASYNAME=${EASYNAME} -i -u ${USERNAME} /home/${USERNAME}/run_user.sh
