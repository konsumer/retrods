#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Builds the diagnostic app (tools/diag) into apps/diag.nds. Run it on the
# console to measure the subsystems the frontend depends on; it writes the
# numbers to fat:/diag.txt so nothing has to be read off a screenshot.
set -eu
cd "$(dirname "$0")/.."

OUT=${1:-apps}
mkdir -p "$OUT"

docker build -q -t retrods-build . > /dev/null

docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$(pwd):/work" -w /work/tools/diag --entrypoint bash retrods-build -c '
make clean > /dev/null 2>&1 || true
make 2>&1 | tail -20
'

cp tools/diag/diag.nds "$OUT/diag.nds"
echo "wrote $OUT/diag.nds ($(wc -c < "$OUT/diag.nds" | tr -d ' ') bytes)"
