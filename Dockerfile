FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]

RUN echo "ALL ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN apt-get update && \
    apt-get -y install swig3.0 \
                      python3-dev \
                      python3-pip \
                      build-essential \
                      pkg-config \
                      libssl-dev \
                      libffi-dev \
                      libhwloc-dev \
                      libboost-dev \
                      wget

RUN cd /usr/local/src \
    && wget https://cmake.org/files/v3.10/cmake-3.10.3.tar.gz \
    && tar xvf cmake-3.10.3.tar.gz \
    && cd cmake-3.10.3 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*

RUN pip3 install -U setupTools
RUN pip3 install -U qrl

# ¡ADD ./config.yml /root/.qrl/config.yml

# public API
EXPOSE 19009

# admin API
EXPOSE 19008

# mining API
EXPOSE 19007

# debug API
EXPOSE 52134

# grpc proxy
EXPOSE 18090

# wallet daemom
EXPOSE 18091

# wallet api
EXPOSE 19010

# p2p
EXPOSE 19000

ENTRYPOINT start_qrl

