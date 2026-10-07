#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Build retrods for the Nintendo DS with the BlocksDS Docker image.
#
#   ./scripts/build.sh          -> retrods.nds       (DS mode)
#   ./scripts/build.sh dsi      -> retrods-dsi.nds   (DSi mode, 133 MHz)

set -eu

cd "$(dirname "$0")/.."

IMAGE=skylyrac/blocksds:slim-latest

if [ ! -d third_party/smsplus/.git ]; then
    echo "third-party cores missing, fetching..."
    ./scripts/fetch-cores.sh
fi

MAKE_ARGS=""
case "${1:-}" in
    "")
        ;;
    dsi|DSI)
        MAKE_ARGS="DSI=1"
        ;;
    *)
        echo "usage: build.sh [dsi]" >&2
        exit 2
        ;;
esac

# Run as the invoking user so build artifacts aren't root-owned on the host.
USER_ARGS=""
if id -u >/dev/null 2>&1; then
    USER_ARGS="--user $(id -u):$(id -g)"
fi

# shellcheck disable=SC2086
docker run --rm $USER_ARGS \
    -v "$(pwd):/work" -w /work --entrypoint bash "$IMAGE" \
    -c "make -j\$(nproc) $MAKE_ARGS"

ls -l ./*.nds
