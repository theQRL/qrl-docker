#!/bin/sh

# Enable this once we deploy through pip packages
#RUN pip install -i https://testpypi.python.org/pypi --extra-index-url https://pypi.python.org/simple/  --upgrade qrl

rm -rf /root/QRL
git clone -b testnet https://github.com/jleni/QRL.git /root/QRL
GITHASH=$(git -C /root/QRL/ rev-parse HEAD)
pip install -r /root/QRL/requirements.txt

echo "GitRepo: " $GITHASH

# qrl binds to 127.0.0.1 so we need some special redirection here
socat -d tcp-listen:18888,reuseaddr,fork tcp:127.0.0.1:8888 &
socat -d tcp-listen:12000,reuseaddr,fork tcp:127.0.0.1:2000 &
socat -d tcp-listen:18080,reuseaddr,fork tcp:127.0.0.1:8080 &

/root/QRL/start_qrl.py
