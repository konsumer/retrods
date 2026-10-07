#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Build one single-core app per emulator: tiny libretro hosts, each holding
# exactly one core. Pico Launcher maps extensions to these (see
# docs/settings-example.json), so it provides the "frontend" and each app stays
# small enough to fit a DS.
#
#   scripts/build-apps.sh [output-dir]        # default: apps/
#
# Each core is built for DS mode when it fits the 4 MiB budget, and falls back to
# a DSi-mode build (16 MiB) when it does not.

set -eu

cd "$(dirname "$0")/.."

OUT=${1:-apps}

CORES=$(ls cores/*.mk | grep -v 'extra\.mk' | xargs -n1 basename | sed 's/\.mk$//' | tr '\n' ' ')

docker build -q -t retrods-build . > /dev/null

docker run --rm -i \
    --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -e CORES="$CORES" -e OUT="$OUT" \
    -v "$(pwd):/work" -w /work \
    --entrypoint bash retrods-build -s <<'INNER'
set -eu

mkdir -p "$OUT"
made=0; failed=0

for core in $CORES; do
    app="retrods-$core"
    title=$(printf '%s' "$core" | cut -c1-12)

    if make -j"$(nproc)" CORES="$core" NAME="$app" BUILD="build-apps/$core" \
            GAME_TITLE="$title" > /tmp/app.log 2>&1; then
        mode=DS
    elif make -j"$(nproc)" DSI=1 CORES="$core" NAME="$app" BUILD="build-apps/$core-dsi" \
            GAME_TITLE="$title" > /tmp/app.log 2>&1; then
        mode=DSi
    else
        printf '%-18s FAILED\n' "$core"
        tail -3 /tmp/app.log | sed 's/^/                     /'
        failed=$((failed + 1))
        continue
    fi

    mv "$app.nds" "$OUT/"
    printf '%-18s %-4s %8s  %s\n' "$core" "$mode" "$(stat -c%s "$OUT/$app.nds")" "$OUT/$app.nds"
    made=$((made + 1))
done

echo
echo "built $made app(s), $failed failed"
INNER
