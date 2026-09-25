# qrl-docker — Ubuntu 20.04 (Focal Fossa)

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/focal.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/focal)

> **amd64 only.** The released `pyqryptonight` and `pyqrandomx` compile with
> `-msse2` and `-maes`, which are x86 instructions, so this image cannot be
> built on arm64. Apple Silicon and other arm64 hosts should use
> [`noble`](../../tree/noble).

This is the **newest branch that builds entirely from upstream theQRL code**.
Everything above it needs the forked dependencies — see
[`master`](../../tree/master) for what that means.

QRL node image built on `ubuntu:20.04` (Python 3.8). Published as
[`qrledger/qrl-docker:focal`](https://hub.docker.com/r/qrledger/qrl-docker).

**The operator guide — ports, data persistence, backup, upgrading and
migration — lives on the [`master`](../../tree/master) branch.** This file
covers only what is specific to Focal.

## Run it

```bash
docker run -d --name qrl-node \
  -p 19000:19000 -p 19009:19009 \
  -v qrl-data:/home/qrl/.qrl \
  qrledger/qrl-docker:focal
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
| Base image | `ubuntu:20.04` |
| Python | 3.8 |
| Runtime libraries | `libssl1.1`, `libffi7`, `libhwloc15`, `libleveldb1d`, `libpython3.8` |
| Dependencies | Upstream — released `pyqrllib` / `pyqryptonight` / `pyqrandomx` from PyPI |
| QRL source | `theQRL/QRL` @ `master` |
| Architecture | `linux/amd64` only |
| Image tag | `qrledger/qrl-docker:focal` |

Everything else — `entrypoint.sh`, `docker-compose.yml`, `.circleci/config.yml`
— is identical across the distro branches. Fixes to those belong on all of
them.

## Build arguments

| Arg | Default | Purpose |
| --- | --- | --- |
| `QRL_REF` | `noble-work-in-progress` | Branch, tag or commit SHA of theQRL/QRL to build |
| `QRL_REPO` | `https://github.com/theQRL/QRL.git` | Source repository (use for forks) |
| `UBUNTU_VERSION` | `20.04` | Base image tag |

```bash
docker build --build-arg QRL_REF=<sha> -t qrl:focal .
```

`QRL_REF` defaults to `master` so this image is built entirely from upstream
theQRL code: `master`'s `requirements.txt` names the released PyPI packages
`pyqrllib`, `pyqryptonight` and `pyqrandomx`. Pointing it at
`noble-work-in-progress` instead would pull personal forks and make this a TEST
build — see the master branch for what that means.

Pin a commit SHA for anything you intend to reproduce; with a branch name,
Docker's layer cache will reuse a clone from weeks ago.
