# qrl-docker — Ubuntu 26.04 (Resolute Raccoon)

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/resolute.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/resolute)

> ### ⚠️ TEST build
>
> This branch builds `theQRL/QRL` `noble-work-in-progress`, whose
> `requirements.txt` pulls `pyqrllib`, `pyqryptonight` and `pyqrandomx` from
> personal forks rather than the released theQRL packages. Those forks carry
> the rework needed for modern Linux and **have not been exercised on a
> production testnet**. This version is undergoing testing.
>
> There is no upstream-only alternative on this Ubuntu release: the released
> packages do not build here. For an image built entirely from theQRL code,
> use the newest branch marked upstream.

QRL node image built on `ubuntu:26.04` (Python 3.14). Published as
[`qrledger/qrl-docker:resolute`](https://hub.docker.com/r/qrledger/qrl-docker).

**The operator guide — ports, data persistence, backup, upgrading and
migration — lives on the [`master`](../../tree/master) branch.** This file
covers only what is specific to Resolute.

## Run it

```bash
docker run -d --name qrl-node \
  -p 19000:19000 -p 19009:19009 \
  -v qrl-data:/home/qrl/.qrl \
  qrledger/qrl-docker:resolute
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
| Base image | `ubuntu:26.04` |
| Python | 3.14 |
| Runtime libraries | `libssl3t64`, `libffi8`, `libhwloc15`, `libleveldb1d`, `libpython3.14` |
| Dependencies | **TEST** — jplomas forks of pyqrllib / pyqryptonight / pyqrandomx |
| QRL source | `theQRL/QRL` @ `noble-work-in-progress` |
| Architecture | `linux/amd64`, `linux/arm64` (one manifest; Docker picks) |
| Image tag | `qrledger/qrl-docker:resolute` |

Everything else — `entrypoint.sh`, `docker-compose.yml`, `.circleci/config.yml`
— is identical across the distro branches. Fixes to those belong on all of
them.

## Build arguments

| Arg | Default | Purpose |
| --- | --- | --- |
| `QRL_REF` | `noble-work-in-progress` | Branch, tag or commit SHA of theQRL/QRL to build |
| `QRL_REPO` | `https://github.com/theQRL/QRL.git` | Source repository (use for forks) |
| `UBUNTU_VERSION` | `26.04` | Base image tag |

```bash
docker build --build-arg QRL_REF=<sha> -t qrl:resolute .
```

`QRL_REF` defaults to the `noble-work-in-progress` branch because that is the
maintained line of QRL source; it is not noble-specific and builds the same on
every branch here. Pin a commit SHA for anything you intend to reproduce — with
a branch name, Docker's layer cache will reuse a clone from weeks ago.

QRL pulls `pyqrllib`, `pyqryptonight` and `pyqrandomx` straight from git as
declared in its own `requirements.txt`, so those are not pinned here.
