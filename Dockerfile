#Download base ubuntu image
FROM ubuntu:14.04

RUN apt-get update && \
    apt-get -y install software-properties-common python-software-properties && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget cmake

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    add-apt-repository -y ppa:tigerite/mint-xorg-update && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update

# Prepare python
RUN apt-get -y install swig3.0 python3.5 python3.5-dev python3-pip libhwloc-dev libboost-dev

RUN pip3 install --upgrade pip setuptools
RUN pip3 install --ignore-installed six

# latest pip is necessary for cmake to work
RUN pip3 install --upgrade cmake
RUN cmake --version

RUN pip3 install -U -r https://raw.githubusercontent.com/theQRL/QRL/master/requirements.txt
RUN pip3 install -U -r https://raw.githubusercontent.com/theQRL/QRL/master/test-requirements.txt

# This is specificfot 
RUN echo "ALL ALL=NOPASSWD: ALL" >> /etc/sudoers
