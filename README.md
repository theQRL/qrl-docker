# qrl-docker — Ubuntu 18.04 (Bionic Beaver)

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/bionic.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/bionic)

QRL node image built on `ubuntu:18.04` (Python 3.6). Published as
[`qrledger/qrl-docker:bionic`](https://hub.docker.com/r/qrledger/qrl-docker).

**The operator guide — ports, data persistence, backup, upgrading and
migration — lives on the [`master`](../../tree/master) branch.** This file
covers only what is specific to Bionic.

> **amd64 only.** The released `pyqryptonight` and `pyqrandomx` compile with
> `-msse2` and `-maes`, which are x86 instructions, so this image cannot be
> built on arm64. Apple Silicon and other arm64 hosts should use
> [`noble`](../../tree/noble).

> **18.04 is past standard support.** It reaches this repo because it is the
> oldest release that still builds upstream theQRL code, not because it is a
> good place to run a node. Prefer [`noble`](../../tree/noble).

## Run it

```bash
docker run -d --name qrl-node \
  -p 19000:19000 -p 19009:19009 \
  -v qrl-data:/home/qrl/.qrl \
  qrledger/qrl-docker:bionic
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
| Base image | `ubuntu:18.04` |
| Python | 3.6 |
| Dependencies | Upstream — released `pyqrllib` / `pyqryptonight` / `pyqrandomx` from PyPI |
| QRL source | `theQRL/QRL` @ `master` |
| Architecture | `linux/amd64` only |
| Runtime libraries | `libssl1.1`, `libffi6`, `libhwloc5`, `libleveldb1v5`, `libpython3.6` |
| Image tag | `qrledger/qrl-docker:bionic` |

Two things differ from the newer branches beyond package names:

- **pip is pinned below 22.** Python 3.6 supports nothing newer, and the
  `PIP_NO_CACHE_DIR=1` the other branches set would crash the pip 9.0.1 that
  3.6's venv bundles — it reads the variable as a path and dies with
  `TypeError: expected str, bytes or os.PathLike object, not int` before the
  upgrade can run. The cache is removed explicitly instead.
- **setuptools is pinned below 60**, because the 2018-era sdists this ref
  builds predate the modern build backend.

## Build arguments

| Arg | Default | Purpose |
| --- | --- | --- |
| `QRL_REF` | `master` | Branch, tag or commit SHA of theQRL/QRL to build |
| `QRL_REPO` | `https://github.com/theQRL/QRL.git` | Source repository (use for forks) |
| `UBUNTU_VERSION` | `18.04` | Base image tag |

`QRL_REF` defaults to `master` so this image is built entirely from upstream
theQRL code: `master`'s `requirements.txt` names the released PyPI packages.
`noble-work-in-progress` cannot be installed here at all — it pins
`Twisted>=25.0.0`, and every Twisted in that range requires Python >= 3.8.

Pin a commit SHA for anything you intend to reproduce; with a branch name,
Docker's layer cache will reuse a clone from weeks ago.
