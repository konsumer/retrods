#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# End-to-end host smoke test. The frontend and the cores are portable C/C++, so
# they are built for the dev machine and run natively with a headless backend
# that dumps frames and audio.
#
# This runs inside the build container because the host build needs the same
# objcopy-based symbol renaming as the DS build (cores share helper code).

set -eu

cd "$(dirname "$0")/.."

IMAGE=retrods-build

docker build -q -t "$IMAGE" . > /dev/null

docker run --rm \
    --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$(pwd):/work" -w /work --entrypoint bash "$IMAGE" -c '
set -eu

echo "== build =="
make -f Makefile.host -j"$(nproc)" CORES="testcore smsplus quicknes gambatte snes9x2002" 2>&1 | tail -3

OUT=build-host/out
mkdir -p "$OUT"

for pair in "sms smsplus" "nes quicknes" "gb gambatte" "sfc snes9x2002"; do
    ext=${pair%% *}
    core=${pair##* }
    echo
    echo "== $core on a generated .$ext ROM =="
    python3 scripts/gen-test-rom.py "$OUT/test.$ext" > /dev/null
    RD_OUTDIR="$OUT" RD_FRAMES=60 ./build-host/retrods-host "$OUT/test.$ext" 2>&1 | sed "s/^/  /"
done

echo
echo "== diagnostic test core =="
printf "retrods test content" > "$OUT/pattern.rdt"
RD_OUTDIR="$OUT" RD_FRAMES=30 ./build-host/retrods-host "$OUT/pattern.rdt" 2>&1 | sed "s/^/  /"

echo
echo "== save states =="
# Save at frame 60, load at frame 120. The animation has to resume where the
# save was taken, so frames 30 later must match (90/150, 120/180). A control run
# with no load proves the frames really do change over that span, which is what
# makes the comparison meaningful rather than trivially true.
printf "retrods state test" > "$OUT/state.rdt"
python3 - "$OUT" <<PYEOF
import hashlib, os, subprocess, sys

out = sys.argv[1]
rom = os.path.join(out, "state.rdt")

def run(input_script):
    state = os.path.join(out, "state.rdt.state")
    if os.path.exists(state):
        os.remove(state)
    env = dict(os.environ, RD_OUTDIR=out, RD_FRAMES="200")
    if input_script:
        env["RD_INPUT"] = input_script
    subprocess.run(["./build-host/retrods-host", rom], env=env,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

def frame(n):
    p = os.path.join(out, "frame_%04d.ppm" % n)
    return hashlib.sha256(open(p, "rb").read()).hexdigest() if os.path.exists(p) else None

run(None)
if frame(90) == frame(150):
    print("  SKIP: this core does not change frames over 60 frames")
    sys.exit(0)

run("60:save,120:load")
if frame(90) == frame(150) and frame(120) == frame(180):
    print("  round trip OK: resumed identically after the load")
else:
    print("  FAILED: did not resume identically")
    sys.exit(1)
PYEOF

echo
echo "== registered cores =="
./build-host/retrods-host 2>&1 | sed "s/^/  /" || true

echo
echo "== artifacts =="
ls -l "$OUT" | tail -6
'
