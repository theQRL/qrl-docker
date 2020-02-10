#Download base debian 10 'buster' image
FROM debian:10
RUN apt-get update && \
    apt-get -y install software-properties-common && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget

# Prepare python
RUN apt-get -y install swig3.0 python3 python3-dev python3-pip python3-venv libhwloc-dev libboost-dev

RUN cd /usr/local/src \
    && wget https://cmake.org/files/v3.10/cmake-3.10.3.tar.gz \
    && tar xvf cmake-3.10.3.tar.gz \
    && cd cmake-3.10.3 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*

RUN pip3 install -U pip setuptools

RUN pip3 install -U setupTools
RUN pip3 install -U qrl

RUN groupadd -g 999 qrl && \
    useradd -r -u 999 -g qrl qrl

RUN mkdir /home/qrl
RUN chown -R qrl:qrl /home/qrl
ENV HOME=/home/qrl
WORKDIR $HOME

USER qrl

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

# environment variables
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENTRYPOINT start_qrl
