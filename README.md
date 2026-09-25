# qrl-docker

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/master)

Docker images for running a [QRL](https://github.com/theQRL/QRL) node.

| Ubuntu | Branch | Image tag | Dependencies | Arch | CI |
|---|---|---|---|---|---|
| 26.04 (Resolute) | [`resolute`](../../tree/resolute) | `:resolute` | ⚠️ **TEST** | amd64 published, arm64 buildable | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/resolute.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/resolute) |
| 24.04 (Noble) | [`noble`](../../tree/noble) | `:noble`, `:latest` | ⚠️ **TEST** | amd64 published, arm64 buildable | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/noble.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/noble) |
| 22.04 (Jammy) | [`jammy`](../../tree/jammy) | `:jammy` | ⚠️ **TEST** | amd64 published, arm64 buildable | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/jammy.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/jammy) |
| 20.04 (Focal) | [`focal`](../../tree/focal) | `:focal` | Upstream theQRL | amd64 only | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/focal.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/focal) |
| 18.04 (Bionic) | [`bionic`](../../tree/bionic) | `:bionic` | Upstream theQRL | amd64 only | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/theQRL/qrl-docker/tree/bionic.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/theQRL/qrl-docker/tree/bionic) |

**Upstream theQRL** means every dependency is a released theQRL package.
**TEST** means the build pulls `pyqrllib`, `pyqryptonight` and `pyqrandomx`
from personal forks that are still undergoing testing — see below.

**Run `:latest` (Noble) unless you have a specific reason not to.**

## Upstream builds and TEST builds

Branches differ in where their QRL dependencies come from, and it matters:

- **Upstream** — built from `theQRL/QRL` `master`, whose `requirements.txt`
  names the released PyPI packages `pyqrllib`, `pyqryptonight` and
  `pyqrandomx`. Everything in the image comes from theQRL.
- **TEST** — built from `theQRL/QRL` `noble-work-in-progress`. The QRL source
  is still theQRL's, but its `requirements.txt` pulls `pyqrllib`,
  `pyqryptonight` and `pyqrandomx` from personal forks carrying the
  modern-Linux rework. **That rework has not been exercised on a production
  testnet.** Treat these images as under test.

The newer Ubuntu releases have no upstream option — the forks are what make
them build at all. The table above marks which is which, and each image records
it as a label you can check without reading any docs:

```bash
docker inspect qrledger/qrl-docker:latest \
  --format '{{index .Config.Labels "org.theqrl.deps"}}'   # upstream | test
docker inspect qrledger/qrl-docker:latest \
  --format '{{index .Config.Labels "org.theqrl.qrl.ref"}}'
```

If you want an upstream-only node, run the newest branch marked upstream.

## How this repo is organised

`master` carries the documentation you are reading — the operator guide that
applies to every image. It has no `Dockerfile`.

Each remaining branch is named after an Ubuntu release and contains a
`Dockerfile` for that release plus a `.circleci/config.yml` that builds it and
pushes it to Docker Hub as `qrledger/qrl-docker:<branch>`. The branch name is
the image tag, so forking a new release branch needs no CI changes.

Only the base image tag, the Python version and a handful of runtime library
package names differ between branches. Everything else — `entrypoint.sh`,
`docker-compose.yml`, the CI config — is identical, and a fix to one should be
carried to all of them. See [Maintaining the branches](#maintaining-the-branches).

> This repo is for **node operators** who want to containerise a QRL node.
> It is not [`qrl-docker-ci`](https://github.com/theQRL/qrl-docker-ci), which
> builds the development environment images used by QRL's own CI. The two
> repos share this branch-per-distro layout but nothing else.

The `Dockerfile` on each branch also doubles as a reference for the recommended
installation steps on that Ubuntu release.

## Quick start

```bash
docker run -d --name qrl-node \
  -p 19000:19000 -p 19009:19009 \
  -v qrl-data:/home/qrl/.qrl \
  qrledger/qrl-docker:latest
docker logs -f qrl-node
```

Only the P2P port (19000) and the public API (19009) are published above. The
admin, mining and wallet APIs are unauthenticated — see
[Security](#security) before exposing them.

The `-v qrl-data:/home/qrl/.qrl` is not optional in practice: without it the
chain state and your wallet live in the container's writable layer and
`docker rm` destroys them.

### Build from source instead

Check out the branch matching the Ubuntu release you want:

```bash
git clone https://github.com/theQRL/qrl-docker.git
cd qrl-docker
git checkout noble
docker compose up -d --build
docker compose logs -f qrl-node
docker compose down                  # stop; named volume is kept
```

### Build arguments

| Arg | Default | Purpose |
| --- | --- | --- |
| `QRL_REF` | branch-specific | Branch, tag or commit SHA of theQRL/QRL to build |
| `QRL_REPO` | `https://github.com/theQRL/QRL.git` | Source repository (use for forks) |
| `UBUNTU_VERSION` | branch-specific | Base image tag |

`QRL_REF` is what decides upstream vs TEST: `master` pulls the PyPI
dependencies, `noble-work-in-progress` pulls the forks. Overriding it on a
branch whose Python is too old for the other ref will simply fail to resolve.

```bash
docker build --build-arg QRL_REF=f1527b1 -t qrl:pinned .
```

Pin `QRL_REF` to a commit SHA for anything you intend to reproduce: with a
branch name, Docker's layer cache will happily reuse a clone from weeks ago.
Force a fresh clone with `docker build --no-cache`.

## Version support

The branches track Ubuntu **LTS** releases. Interim releases get nine months of
updates, which is the wrong footing for a node meant to stay up.

There is a hard line between 20.04 and 22.04:

- **20.04 and older build upstream theQRL code.** `theQRL/QRL` `master` pins
  the 2018-era dependency set, and those releases can still satisfy it.
- **22.04 and newer cannot.** `master` pins `cryptography==2.3`, which predates
  OpenSSL 3.0, and `Twisted==20.3.0`; their sdists' `setup.py` files import
  `pkg_resources`, which setuptools >= 81 no longer ships. PEP 517 build
  isolation installs the newest setuptools into a throwaway environment and
  `PIP_CONSTRAINT` is not applied there, so the pin cannot be forced from
  outside. Building without isolation works around that but then breaks
  Twisted 20.3.0, whose `incremental`-based versioning resolves to `0.0.0`.

So the newest release with an upstream build is **`focal`**, and everything
above it is a TEST build. That is not a packaging preference — it is what the
forks exist to fix.

### Architecture

The released `pyqryptonight` and `pyqrandomx` compile with `-msse2` and
`-maes`, which are x86 instructions, so **the upstream branches are amd64
only**. The forked dependencies build on both, which is why the TEST branches
are the only ones that can produce an arm64 image at all.

There are no per-architecture branches, and adding them would not help. The
`Dockerfile` does not differ by architecture — the `-msse2`/`-maes` flags are
inside an upstream dependency, so a `bionic-arm64` branch would be a
byte-identical copy of `bionic` that still fails to build. Instead each tag is
a manifest list, and the tag carries whichever architectures CI built.

**CI currently publishes `linux/amd64` only.** The runners are x86, so an arm64
image has to be built under QEMU, and the vendored C++ extensions take 20-30
minutes to compile that way (measured: 1376s and 1617s for the equivalent
emulated builds). That is too slow to sit in every push, so arm64 is off by
default and enabled with `BUILD_ARM64=1` — which is only worth doing on a
native Arm runner, not under emulation.

On an arm64 host, build the branch locally in the meantime; it compiles
natively in a few minutes:

```bash
git checkout noble && docker compose up -d --build
```

Swapping the forked dependencies into an upstream build to get arm64 on the
older releases does not work either: the forked `pyqryptonight` reports version
`0.1.0+196.g1bfe3a4`, which does not satisfy `master`'s `pyqryptonight>=0.99.9`.
The fix belongs upstream — publishing arm64 wheels, or guarding those compiler
flags behind an architecture check, would make `bionic` and `focal` build on
arm64 with no change to this repo.

## Ports

| Port | Service | Safe to expose publicly? |
| --- | --- | --- |
| 19000 | P2P networking | Yes — required to sync |
| 19009 | gRPC public API | Yes, if you intend to serve queries |
| 19007 | gRPC mining API | No |
| 19008 | gRPC admin API | **No** — node administration |
| 19010 | Secondary P2P | Only if configured |
| 18090 | Wallet daemon | **No** |
| 18091 | Wallet HTTP API | **No** |
| 52134 | gRPC proxy | No |

`docker-compose.yml` binds everything except 19000 and 19009 to `127.0.0.1`.

## Data persistence

Everything the node needs to keep lives in `/home/qrl/.qrl`, declared as a
volume and mapped to the named volume `qrl-data` by Compose:

```
/home/qrl/.qrl/
├── config.yml            # your settings, if you created one
├── wallet.json           # seed material for every address it lists
├── qrl.log
└── data/
    ├── known_peers.json
    └── state/            # LevelDB chain state — the bulk of the volume
```

The volume survives image rebuilds and upgrades. The node runs as `qrl`
(UID/GID 999), which is fixed across every branch so the same data directory
works with any of these images.

### Where a wallet gets written

**These images contain no wallet.** One exists only once you create it with
`qrl wallet_gen`. This section is about where that file lands, because the
default is wrong in a way that is easy to miss.

The QRL CLI takes its wallet location from `--wallet_dir`, which upstream
defaults to `'.'` — the process's working directory. With `WORKDIR /home/qrl`
that resolves to `/home/qrl/wallet.json`: one level *above* the data directory,
in the container's writable layer rather than the mounted volume. A node set up
that way loses its wallet to `docker rm` while the chain state survives, which
is the worst shape for that failure — everything looks healthy until the wallet
is gone.

Every branch here therefore sets

```dockerfile
ENV ENV_QRL_WALLET_DIR=/home/qrl/.qrl
```

so a wallet you create is written into the data directory, on the volume, where
the backup and upgrade instructions below will actually find it.

Check it on your own node — the path the CLI prints is the truth:

```bash
docker exec -it --user qrl qrl-node qrl wallet_gen --encrypt
# Wallet at : /home/qrl/.qrl/wallet.json      <- on the volume, correct
# Wallet at : /home/qrl/wallet.json           <- container layer, will be lost
```

If you see the second path you are on an image without this setting — an older
qrl-docker image, or a `qrl` CLI run outside these images. Move the file into
the data directory before removing that container.

## Configuration

The node reads its settings from `config.yml` inside the data directory
(`/home/qrl/.qrl/config.yml`). Edit it on the volume and restart the container:

```bash
docker exec -it --user qrl qrl-node sh -c 'cat ~/.qrl/config.yml'
docker restart qrl-node
```

To run with debug logging, override the command:

```yaml
# docker-compose.override.yml
services:
  qrl-node:
    command: ["start_qrl", "--debug"]
```

Debug logging is off by default because it produces megabytes of log output per
hour.

## Useful commands

Pass `--user qrl` to `docker exec`: `exec` bypasses the entrypoint, so without
it commands run as root and leave root-owned files in the data volume.

```bash
docker exec -it --user qrl qrl-node qrl                    # list all CLI commands
docker exec -it --user qrl qrl-node qrl state              # node status
docker exec -it --user qrl qrl-node qrl wallet_gen --encrypt   # new encrypted wallet
docker exec -it --user qrl qrl-node qrl wallet_ls          # list addresses
docker exec -it --user qrl qrl-node bash                   # shell in the container
docker stats qrl-node                                      # resource usage
```

Always use `--encrypt` when generating a wallet you intend to keep.

## Backup and recovery

Stop the node first so the state files are consistent:

```bash
docker stop qrl-node
docker cp qrl-node:/home/qrl/.qrl/. ./backup/
docker start qrl-node
```

`wallet.json` lives inside the data directory (`/home/qrl/.qrl/wallet.json`)
on these images, so the copy above takes the chain state, the config and the
wallet together. On an older image it may instead be at `/home/qrl/wallet.json`
— see [Where a wallet gets written](#where-a-wallet-gets-written).
Grab it too if it is there; the command is harmless when it is not:

```bash
docker cp qrl-node:/home/qrl/wallet.json ./backup/wallet.legacy.json 2>/dev/null || true
```

Restore the same way, in reverse:

```bash
docker stop qrl-node
docker run --rm -v qrl-data:/dest -v "$PWD/backup":/src:ro alpine \
  sh -c 'cp -a /src/. /dest/ && chown -R 999:999 /dest'
docker start qrl-node
```

> **A wallet backup is the wallet.** `wallet.json` contains the seed material
> for every address it lists. Encrypting it protects it only as well as your
> passphrase. Keep backups off this repository (`backup/` is gitignored), out of
> the Docker build context (`.dockerignore` excludes it), and encrypted at rest.

## Updating

Updating the node means replacing the container, never the volume:

```bash
docker pull qrledger/qrl-docker:latest
docker stop qrl-node && docker rm qrl-node
docker run -d --name qrl-node \
  -p 19000:19000 -p 19009:19009 \
  -v qrl-data:/home/qrl/.qrl \
  qrledger/qrl-docker:latest
```

Or, building from a branch:

```bash
git pull
docker compose build --pull
docker compose up -d
```

`docker rm` removes the container, not the named volume, so blockchain data and
wallets are preserved. The one command that *does* destroy data is
`docker compose down -v` — the `-v` deletes the volume. There is no undo.

### Moving between Ubuntu branches

The data directory is portable across every branch: same paths, same UID/GID.
To move a running node from, say, `jammy` to `noble`, point a new container at
the same volume:

```bash
docker stop qrl-node && docker rm qrl-node
docker run -d --name qrl-node \
  -p 19000:19000 -p 19009:19009 \
  -v qrl-data:/home/qrl/.qrl \
  qrledger/qrl-docker:noble
docker exec -it --user qrl qrl-node qrl state
```

Take a backup first anyway — it costs one command and the chain state is the
expensive thing to rebuild.

## Migrating from an older qrl-docker

Older branches of this repo (`bionic` and earlier) shipped a single-stage image
that declared no volume:

```dockerfile
# bionic, as it was
RUN pip3 install -U qrl
ENV HOME=/home/qrl
USER qrl
ENTRYPOINT start_qrl
```

With no `VOLUME` declaration, everything the node wrote went into the
container's own writable layer, so chain state and wallet were destroyed by
`docker rm`. Every current branch declares `VOLUME /home/qrl/.qrl` and Compose
maps it to the named volume `qrl-data`.

Two things keep the migration to a plain file copy:

- **The chain state paths are unchanged.** Old and new images both set
  `HOME=/home/qrl`, and the node derives the rest from it — `~/.qrl/data/state`
  (LevelDB chain state), `~/.qrl/data/known_peers.json` and `~/.qrl/config.yml`.
- **The UID/GID is unchanged.** Both images run the node as `qrl` = 999:999, so
  copied files are already owned correctly — and the entrypoint fixes ownership
  if they are not.

> **The wallet is the exception — read this before you `docker rm` anything.**
> The old images did not set `ENV_QRL_WALLET_DIR`, so the CLI defaulted
> `--wallet_dir` to the working directory and wrote **`/home/qrl/wallet.json`**,
> one level above the data directory. Copying `.qrl` alone leaves your wallet
> behind, and because the old image declared no volume that file is in the
> container's writable layer — `docker rm` destroys it. Take it first:
>
> ```bash
> docker stop <old-container>
> docker cp <old-container>:/home/qrl/wallet.json ./backup/wallet.json
> ```
>
> Then drop it into the new volume alongside the migrated state, where
> `ENV_QRL_WALLET_DIR` will now find it:
>
> ```bash
> docker run --rm -v qrl-data:/dest -v "$PWD/backup":/src:ro alpine \
>   sh -c 'cp -a /src/wallet.json /dest/ && chown 999:999 /dest/wallet.json'
> ```
>
> Verify with `docker exec -it --user qrl qrl-node qrl wallet_ls` before
> deleting the old container.

Start by finding where the old data actually lives:

```bash
docker inspect <old-container> --format '{{json .Mounts}}'
```

### No mounts listed — the data is in the container layer

The default for the old image. Copy the *contents* of `.qrl` out, then into a
new named volume:

```bash
docker stop <old-container>
mkdir -p ./backup/old-node
docker cp <old-container>:/home/qrl/.qrl/. ./backup/old-node/   # note the trailing /.
# and the wallet, which on an old image sits one level up (see the warning above)
docker cp <old-container>:/home/qrl/wallet.json ./backup/old-node/ 2>/dev/null || true

docker volume create qrl-data
docker run --rm -v qrl-data:/dest -v "$PWD/backup/old-node":/src:ro alpine \
  sh -c 'cp -a /src/. /dest/ && chown -R 999:999 /dest'
```

Keep `./backup/old-node` until the new node is verified — it is a complete copy
of the old one, and `backup/` is already excluded from git and from the Docker
build context.

### A 64-character hex mount name — an anonymous volume

Created by running the old image with `-v /home/qrl/.qrl` and no volume name.
Nothing needs copying; point the new stack straight at it:

```yaml
# docker-compose.override.yml
volumes:
  qrl-data:
    external: true
    name: <hex-name>
```

Or copy it into a fresh named volume if you would rather keep the old one
intact:

```bash
docker run --rm -v <hex-name>:/src:ro -v qrl-data:/dest alpine cp -a /src/. /dest/
```

### A host path — a bind mount

Also nothing to copy. Reuse the same path:

```yaml
# docker-compose.override.yml
services:
  qrl-node:
    volumes:
      - /srv/qrl:/home/qrl/.qrl
```

### Verify before deleting anything

```bash
docker compose up -d
docker compose logs -f qrl-node
docker exec -it --user qrl qrl-node qrl state       # height near where the old node stopped
docker exec -it --user qrl qrl-node qrl wallet_ls   # your addresses
```

A node that resumes from the migrated state syncs the last few blocks and
settles. A node that starts at height 0 is not reading your data — see below.

### Do not nest `.qrl`

The usual mistake. `docker cp <old-container>:/home/qrl/.qrl ./backup` creates
`./backup/.qrl`, and copying *that* into the volume produces
`/home/qrl/.qrl/.qrl/data/state`. The node ignores it and resyncs from genesis.
The volume root must hold `data/`, not another `.qrl/`:

```bash
docker run --rm -v qrl-data:/d:ro alpine ls -la /d
```

Expect `data/`, `qrl.log` and — once migrated — `wallet.json` at that top
level, where `ENV_QRL_WALLET_DIR` points.

### If the node will not start on the migrated state

Chain state written by a much older QRL release is not guaranteed to be
readable by a current one; the node exits at startup rather than upgrading the
database in place. The wallet is independent of the chain state, so the
recovery is to keep the wallet and resync:

```bash
docker stop qrl-node
docker run --rm -v qrl-data:/d alpine \
  sh -c 'cp -a /d/wallet.json /d/wallet.json.bak 2>/dev/null; rm -rf /d/data'
docker start qrl-node
```

The resync re-downloads the chain from peers and takes hours. Addresses and
balances are recovered from the chain — `wallet.json` holds the keys, not the
funds, so nothing is lost by discarding `data/`.

## Security

- The node process runs as the unprivileged `qrl` user (UID/GID 999). The
  entrypoint starts as root only to fix ownership of a freshly created volume,
  then drops privileges with `gosu`.
- The build tools are confined to a builder stage, so the shipped image contains
  no compilers, headers or source checkout.
- Expose only 19000 and 19009. The admin, mining and wallet APIs have no
  authentication — anything that can reach them can control the node.
- Rebuild periodically to pick up Ubuntu security updates for the base image.
  CI rebuilds the `:latest` branch weekly for this reason.

## Multi-architecture builds

CI publishes `linux/amd64` only. To build for your own architecture, or both:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t qrl:latest .
```

On Apple Silicon or another arm64 host, building the branch locally is
currently the way to get a native image.

## Maintaining the branches

Each distro branch holds the same files:

```
Dockerfile           multi-stage build (builder → runtime)
entrypoint.sh        volume ownership fix + privilege drop
docker-compose.yml   single-node deployment
.circleci/config.yml build and push to qrledger/qrl-docker:<branch>
.dockerignore        keeps backup/ and wallets out of the build context
```

To fork a branch for a new Ubuntu LTS:

1. Branch from the newest existing distro branch, named after the new codename.
2. In `Dockerfile`, bump `ARG UBUNTU_VERSION` and fix the runtime library
   package names. They are renamed between releases more often than you would
   expect — `libssl1.1` → `libssl3` → `libssl3t64`, `libffi6` → `libffi7` →
   `libffi8`, `libleveldb1v5` → `libleveldb1d`, and `libpythonX.Y` tracks the
   release's Python. Resolve them against the real base image rather than
   guessing:

   ```bash
   docker run --rm ubuntu:<version> sh -c \
     'apt-get update -qq >/dev/null 2>&1; apt-get install -s -y --no-install-recommends \
      ca-certificates gosu libffi8 libhwloc15 libleveldb1d libpython3.14 libssl3t64 python3 \
      >/dev/null && echo OK || echo FAIL'
   ```

3. Change `image:` in `docker-compose.yml` to match the branch.
4. Add a row to the table at the top of this file.
5. Nothing in `.circleci/config.yml` changes — it tags from `$CIRCLE_BRANCH`.
   When the new branch is ready to be the default, move the `latest_branch`
   pipeline parameter to it.

CI needs two project environment variables: `DOCKERHUB_USERNAME` and
`DOCKERHUB_TOKEN`.

## Windows

Run PowerShell as Administrator before running the Docker CLI commands.
