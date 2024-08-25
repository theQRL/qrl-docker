FROM ubuntu:22.04
CMD ["--debug"]

RUN apt-get update -y 
RUN apt-get upgrade -y
RUN apt-get -y install build-essential \
                        pkg-config \
                        swig3.0 \
                        python3-dev \
                        python3-pip \
                        python3-venv \
                        libhwloc-dev \
                        libboost-dev \
                        libffi-dev \
                        libleveldb-dev \
                        python3-six \
                        cmake \
                        libssl-dev

RUN groupadd -g 999 qrl && \
    useradd -r -u 999 -g qrl qrl

RUN mkdir /home/qrl
RUN chown -R qrl:qrl /home/qrl
ENV HOME=/home/qrl
WORKDIR $HOME
USER qrl
ENV PATH "$PATH:/home/qrl/.local/bin"

RUN pip3 install -U setuptools  

RUN pip3 install service-identity==21.1.0
RUN pip3 install -U qrl

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

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENTRYPOINT ["start_qrl"]
