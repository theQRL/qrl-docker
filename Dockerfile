#Download base ubuntu image
FROM ubuntu:16.04
RUN apt-get update && \
    apt-get -y install software-properties-common python-software-properties && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential git sudo wget nano && \
    apt-get -y install swig3.0 python3 python3-dev python3-pip cmake pkg-config

RUN pip3 install --upgrade pip virtualenv setuptools twine PyScaffold

# Install nodejs
RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash

RUN echo "ALL ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN cd ${HOME} && \
    curl -O https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz && \
    tar -xvzf emsdk-portable.tar.gz

RUN cd /root/emsdk-portable && ./emsdk update
RUN cd /root/emsdk-portable && ./emsdk install latest
RUN cd /root/emsdk-portable && ./emsdk activate latest
# RUN cd /root/emsdk-portable && source ./emsdk_env.sh
