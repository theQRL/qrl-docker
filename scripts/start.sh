#!/bin/sh

# qrl binds to 127.0.0.1 so we need some special redirection here
socat -d tcp-listen:18888,reuseaddr,fork tcp:127.0.0.1:8888 &
socat -d tcp-listen:12000,reuseaddr,fork tcp:127.0.0.1:2000 &
socat -d tcp-listen:18080,reuseaddr,fork tcp:127.0.0.1:8080 &

/root/QRL/start_qrl.py
