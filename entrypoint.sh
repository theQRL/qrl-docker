#!/bin/sh
# Prepare the mounted data volume and drop privileges to the qrl user.
set -e

QRL_HOME=${QRL_HOME:-/home/qrl}
DATA_DIR="$QRL_HOME/.qrl"

if [ "$(id -u)" = "0" ]; then
    mkdir -p "$DATA_DIR"

    # A fresh named volume (or a bind mount from the host) arrives owned by
    # root. Only recurse when the ownership is actually wrong: the chain state
    # grows to tens of GB and an unconditional `chown -R` would add minutes to
    # every start.
    if [ "$(stat -c %u "$DATA_DIR")" != "$(id -u qrl)" ]; then
        chown -R qrl:qrl "$DATA_DIR"
    fi

    exec gosu qrl "$@"
fi

# Started with `--user`, so we are already unprivileged.
exec "$@"
