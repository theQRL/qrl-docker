# QRL node on Ubuntu 20.04 (Focal).
#
# Two stages: the builder holds the compilers and -dev headers needed to build
# pyqrllib / pyqryptonight / pyqrandomx, the runtime image ships only the
# finished virtualenv plus the shared libraries QRL actually loads at run time.
#
# Branch-specific values (base tag, Python 3.8, runtime library package names)
# are the ONLY thing that differs from the other distro branches of this repo.

ARG UBUNTU_VERSION=20.04
ARG VENV=/opt/qrl/venv

# --------------------------------------------------------------- builder ---
FROM ubuntu:${UBUNTU_VERSION} AS builder

ARG VENV
ARG QRL_REPO=https://github.com/theQRL/QRL.git
# Branch, tag or commit SHA. Pin a SHA for reproducible, cache-correct builds:
#   docker build --build-arg QRL_REF=<sha> .
# theQRL/QRL master: its requirements.txt names the released PyPI packages
# (pyqrllib, pyqryptonight, pyqrandomx), so this image is built entirely from
# upstream theQRL code and carries no personal forks.
ARG QRL_REF=master

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        libboost-dev \
        libffi-dev \
        libhwloc-dev \
        libleveldb-dev \
        libssl-dev \
        pkg-config \
        python3-dev \
        python3-venv \
        swig \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="${VENV}/bin:${PATH}"
RUN python3 -m venv "${VENV}"

# pyqrllib 1.2.x (the PyPI release theQRL/QRL master pins) has a setup.py that
# imports pkg_resources, which setuptools >= 81 no longer ships. PEP 517 build
# isolation would otherwise pull the newest setuptools into the build env and
# fail with "ModuleNotFoundError: No module named 'pkg_resources'". pip applies
# PIP_CONSTRAINT to build dependencies too, so this reaches the isolated env.
RUN echo "setuptools<81" > /etc/pip-constraints.txt
ENV PIP_CONSTRAINT=/etc/pip-constraints.txt

# --filter=blob:none keeps the clone small while still allowing QRL_REF to be a
# branch, tag or commit SHA. The source tree is removed in the same layer so it
# never reaches the runtime image.
#
# WORKAROUND: QRL gained a pyproject.toml, so pip now builds it under PEP 517
# isolation. setup.cfg sets include_package_data = True, but MANIFEST.in lists
# only versioneer files and the isolated build environment has no setuptools-scm
# file finder — so genesis.yml, config.yml and the .proto files are silently
# dropped from the wheel and the node dies at startup with
# "FileNotFoundError: .../qrl/core/genesis.yml". Adding the recursive-include
# restores them. Remove this line once MANIFEST.in is fixed upstream.
RUN git clone --filter=blob:none --no-checkout "${QRL_REPO}" /tmp/QRL \
    && git -C /tmp/QRL checkout "${QRL_REF}" -- \
    && echo "recursive-include src/qrl *.yml *.proto *.csv *.json" >> /tmp/QRL/MANIFEST.in \
    && pip install --upgrade pip setuptools wheel \
    && pip install --requirement /tmp/QRL/requirements.txt \
    && pip install /tmp/QRL \
    && rm -rf /tmp/QRL /root/.cache

# --------------------------------------------------------------- runtime ---
FROM ubuntu:${UBUNTU_VERSION} AS runtime

ARG VENV

LABEL org.opencontainers.image.title="qrl-docker" \
      org.opencontainers.image.description="QRL node on Ubuntu 20.04 Focal" \
      org.opencontainers.image.source="https://github.com/theQRL/qrl-docker" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="ubuntu:20.04" \
      maintainer="deploy@theqrl.org" \
      org.theqrl.qrl.ref="master" \
      org.theqrl.deps="upstream"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    TZ=UTC \
    QRL_HOME=/home/qrl \
    HOME=/home/qrl \
    PATH="${VENV}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Runtime shared libraries only — no compilers, no headers.
# netbase provides /etc/services. Without it getaddrinfo() cannot resolve the
# "ntp" service name and the node exits at startup with
#   aierror(-8, 'Servname not supported for ai_socktype')
#   Could not contact NTP servers after 6 retries
# It happens to arrive as a transitive dependency on some releases and not
# others (24.04 and 26.04 yes, 20.04 and 22.04 no), so name it explicitly
# rather than relying on another package to drag it in.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gosu \
        libffi7 \
        libhwloc15 \
        libleveldb1d \
        libpython3.8 \
        libssl1.1 \
        netbase \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# Fixed UID/GID 999 so bind-mounted host data keeps stable ownership, and so
# data migrated from an older qrl-docker image is already owned correctly.
RUN groupadd --system --gid 999 qrl \
    && useradd --system --uid 999 --gid 999 --home-dir /home/qrl --shell /usr/sbin/nologin qrl \
    && mkdir -p /home/qrl/.qrl \
    && chown -R qrl:qrl /home/qrl

COPY --from=builder --chown=root:root ${VENV} ${VENV}
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /home/qrl

# The QRL CLI resolves its wallet with `--wallet_dir`, which upstream defaults
# to '.' (see qrl/cli.py). With WORKDIR /home/qrl that puts wallet.json in the
# container's writable layer, OUTSIDE the mounted volume — so `docker rm` would
# destroy the wallet while the chain state survived. Point it into the data
# directory so the wallet lives on the volume with everything else.
#   Verified: `qrl wallet_gen` then reports "Wallet at: /home/qrl/.qrl/wallet.json".
ENV ENV_QRL_WALLET_DIR=/home/qrl/.qrl

# 19000  P2P networking
# 19007  gRPC mining API
# 19008  gRPC admin API
# 19009  gRPC public API
# 19010  secondary P2P
# 18090  wallet daemon
# 18091  wallet HTTP API
# 52134  gRPC proxy
EXPOSE 19000 19007 19008 19009 19010 18090 18091 52134

VOLUME ["/home/qrl/.qrl"]

HEALTHCHECK --interval=60s --timeout=5s --start-period=180s --retries=3 \
    CMD python3 -c "import socket; socket.create_connection(('127.0.0.1', 19009), 3).close()"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["start_qrl"]
