# qrl-docker — Ubuntu 22.04 (Jammy Jellyfish)

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/jammy.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/jammy)

> ### ⚠️ TEST build
>
> This branch builds `theQRL/QRL` `noble-work-in-progress`, whose
> `requirements.txt` pulls `pyqrllib`, `pyqryptonight` and `pyqrandomx` from
> personal forks rather than the released theQRL packages. Those forks carry
> the rework needed for modern Linux and **have not been exercised on a
> production testnet**. This version is undergoing testing.
>
> Upstream `theQRL/QRL` `master` does not build on 22.04 — its 2018-era pins
> (`cryptography==2.3`, `Twisted==20.3.0`) predate this release's OpenSSL 3.0
> and setuptools. 20.04 (`focal`) is the newest branch with an upstream build.

QRL node image built on `ubuntu:22.04` (Python 3.10). Published as
[`qrledger/qrl-docker:jammy`](https://hub.docker.com/r/qrledger/qrl-docker).

**The operator guide — ports, data persistence, backup, upgrading and
migration — lives on the [`master`](../../tree/master) branch.** This file
covers only what is specific to Jammy.

## Run it

```bash
docker run -d --name qrl-node \
  -p 19000:19000 -p 19009:19009 \
  -v qrl-data:/home/qrl/.qrl \
  qrledger/qrl-docker:jammy
```

Or build this branch:

```bash
docker compose up -d --build
docker compose logs -f qrl-node
```

Do not drop the `-v qrl-data:/home/qrl/.qrl`. Without it the chain state and
your wallet live in the container's writable layer and `docker rm` destroys
them.

## What is specific to this branch

| | |
|---|---|
| Base image | `ubuntu:22.04` |
| Python | 3.10 |
| Runtime libraries | `libssl3`, `libffi8`, `libhwloc15`, `libleveldb1d`, `libpython3.10` |
| Dependencies | **TEST** — jplomas forks of pyqrllib / pyqryptonight / pyqrandomx |
| QRL source | `theQRL/QRL` @ `noble-work-in-progress` |
| Architecture | `linux/amd64`, `linux/arm64` (one manifest; Docker picks) |
| Image tag | `qrledger/qrl-docker:jammy` |

Everything else — `entrypoint.sh`, `docker-compose.yml`, `.circleci/config.yml`
— is identical across the distro branches. Fixes to those belong on all of
them.

## Build arguments

| Arg | Default | Purpose |
| --- | --- | --- |
| `QRL_REF` | `noble-work-in-progress` | Branch, tag or commit SHA of theQRL/QRL to build |
| `QRL_REPO` | `https://github.com/theQRL/QRL.git` | Source repository (use for forks) |
| `UBUNTU_VERSION` | `22.04` | Base image tag |

```bash
docker build --build-arg QRL_REF=<sha> -t qrl:jammy .
```

`QRL_REF` defaults to `noble-work-in-progress`, which is what makes this a TEST
build. Pin a commit SHA for anything you intend to reproduce; with a branch
name, Docker's layer cache will reuse a clone from weeks ago.
