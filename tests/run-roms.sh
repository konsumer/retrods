#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Run one real ROM per core through the host build and report which cores
# actually emulate. Builds every core in the tree (the host has no RAM limit).
#
#   tests/run-roms.sh <rom-directory> [frames]
#
# Each core is tried against the first file below <rom-directory> whose
# extension it claims.

set -eu

cd "$(dirname "$0")/.."

[ "$#" -ge 1 ] || { echo "usage: run-roms.sh <rom-directory> [more directories...]" >&2; exit 2; }
FRAMES=${RD_FRAMES:-120}

# every directory given is mounted read-only and searched for ROMs
MOUNTS=""; SEARCH=""; SYS_DIR=""; i=0
for d in "$@"; do
    [ -d "$d" ] || { echo "not a directory: $d" >&2; exit 2; }
    MOUNTS="$MOUNTS -v $d:/roms$i:ro"
    SEARCH="$SEARCH /roms$i"
    # the system directory must be the path *inside* the container, not the
    # host path, or firmware-dependent cores cannot find their BIOS
    if [ -z "$SYS_DIR" ] && [ -d "$d/bios" ]; then
        SYS_DIR="/roms$i/bios"
    fi
    i=$((i + 1))
done

CORES=$(ls cores/*.mk | grep -v 'extra\.mk' | xargs -n1 basename | sed 's/\.mk$//' | tr '\n' ' ')

docker build -q -t retrods-build . > /dev/null

docker run --rm -i \
    --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -e CORES="$CORES" -e FRAMES="$FRAMES" -e SEARCH="$SEARCH" \
    -e RUN_TIMEOUT="${RUN_TIMEOUT:-90}" \
    -e SYS_DIR="$SYS_DIR" \
    -v "$(pwd):/work" $MOUNTS -w /work \
    --entrypoint bash retrods-build -s <<'INNER'
set -eu

make -f Makefile.host -j"$(nproc)" CORES="$CORES" > /tmp/.build.log 2>&1 || {
    echo "host build FAILED"; tail -5 /tmp/.build.log; exit 1
}

# The firmware directory is <app dir>/bios, derived from argv[0]. Link it here
# so the tests exercise that default rather than overriding it with RD_SYSTEM_DIR.
if [ -n "${SYS_DIR:-}" ]; then
    mkdir -p build-host
    ln -sfn "$SYS_DIR" build-host/bios
fi

OUT=/tmp/out; mkdir -p "$OUT"
# A core that never returns from retro_run must not hang the whole suite (a
# synthetic .mgw did exactly that). A normal run here takes well under a second.
RUN_TIMEOUT=${RUN_TIMEOUT:-90}
pass=0; fail=0; norom=0; needbios=0

# A few cores need a specific ROM to show what they can do. The first .crt
# alphabetically in this collection is a cartridge that never initialises the
# SID, so the C64 row uses one that does (see docs/TESTING.md).
preferred_rom() {
    case "$1" in
    vice_x64) echo "Beamrider*.crt" ;;
    esac
}

try() {
    core="$1"; shift
    rom=""
    pat=$(preferred_rom "$core")
    [ -n "$pat" ] && rom=$(find $SEARCH -type f -not -path "*/bios/*" -iname "$pat" | head -1)
    if [ -z "$rom" ]; then
        for e in "$@"; do
            rom=$(find $SEARCH -type f -not -path "*/bios/*" -iname "*.$e" | head -1)
            [ -n "$rom" ] && break
        done
    fi
    synth=0
    if [ -z "$rom" ]; then
        # no real ROM in the collection: fall back to a generated one so the
        # core is at least exercised (see scripts/gen-test-rom.py)
        for e in "$@"; do
            if python3 scripts/gen-test-rom.py "/tmp/synth.$e" > /dev/null 2>&1; then
                rom="/tmp/synth.$e"; synth=1; break
            fi
        done
    fi
    if [ -z "$rom" ]; then
        printf '%-18s --    no ROM for %s\n' "$core" "$*"
        norom=$((norom + 1)); return
    fi
    rc=0
    out=$(RD_OUTDIR="$OUT" RD_FRAMES="$FRAMES" timeout "$RUN_TIMEOUT" \
          ./build-host/retrods-host --core="$core" "$rom" 2>&1) || rc=$?
    if [ "$rc" = 124 ]; then
        printf '%-18s HANG  no frame after %ss\n' "$core" "$RUN_TIMEOUT"
        fail=$((fail + 1)); return
    fi
    if ! printf '%s' "$out" | grep -q 'video ' && printf '%s' "$out" | grep -qiE 'error loading (bios|firmware)|(bios|firmware)[^ ]* (not found|missing)'; then
        # not a frontend or core failure: the core wants a copyrighted system
        # BIOS that is not part of a ROM collection
        printf '%-18s --    needs a system BIOS
' "$core"
        printf '%s\n' "$out" | grep -iE 'bios|firmware' | head -1 | sed 's/^/                       /'
        needbios=$((needbios + 1))
    elif printf '%s' "$out" | grep -q 'video '; then
        g=$(printf '%s' "$out" | grep -o 'video [0-9]*x[0-9]*' | head -1)
        [ "$synth" = 1 ] && tag=" (synth)" || tag=""
        printf '%-18s OK    %-14s %s%s\n' "$core" "$g" "$(basename "$rom")" "$tag"
        pass=$((pass + 1))
        if [ "$core" = vice_x64 ]; then
            # a running C64 keeps the SID busy; silence here means it stalled
            peak=$(python3 -c "
import wave, array, sys
try:
    w = wave.open('$OUT/audio.wav'); a = array.array('h', w.readframes(w.getnframes()))
    print(max(abs(x) for x in a) if len(a) else 0)
except Exception:
    print(0)")
            if [ "${peak:-0}" -gt 0 ]; then
                printf '%-18s audio peak %s\n' "" "$peak"
            else
                printf '%-18s SILENT - the emulated C64 did not start the program\n' ""
                fail=$((fail + 1)); pass=$((pass - 1))
            fi
        fi
    else
        printf '%-18s FAIL  %s\n' "$core" "$(basename "$rom")"
        printf '%s\n' "$out" | grep -iE 'error|reject|cannot|fail|unsupport' | head -2 | sed 's/^/                       /'
        fail=$((fail + 1))
    fi
}

echo '=== cores run against real ROMs ==='
try stella2014       a26
try prosystem        a78
try handy            lnx
try quicknes         nes
try fceumm           nes fds
try gambatte         gb gbc
try gpsp             gba
try beetle_gba       gba
try snes9x2005       smc sfc
try snes9x2002       smc sfc
try genesis_plus_gx  gen md bin

try smsplus          sms gg col
try freeintv         int
try beetle_ngp       ngp ngc ngpc
try beetle_wswan     ws wsc pc2
try beetle_pce_fast  pce
try beetle_supergrafx sgx pce
try pokemini         min
try cap32            dsk cpc
try vecx             vec
try beetle_vb        vb
try freechaf         chf
try fuse             z80 sna tzx szx

try potator          sv
try gw               mgw
try atari800         atr xex car
try vice_x64         crt d64
try o2em             o2

try fmsx            rom

try testcore         rdt

echo
echo '=== extension -> core mapping (single-core build, as the apps ship) ==='
map_pass=0; map_fail=0

# check_map <core> <ext>...: build the host with ONLY that core -- exactly what
# apps/retrods-<core>.nds contains -- then open a matching ROM *without*
# --core, so the core is chosen by file extension the way Pico Launcher does it.
# The matrix above forces --core, which hides a core that fails to claim an
# extension it should: cap32 used to omit .dsk, so CPC disk images were opened
# by fmsx.
check_map() {
    want="$1"; shift
    if ! make -f Makefile.host -j"$(nproc)" CORES="testcore $want" > /tmp/.map.log 2>&1; then
        printf '%-18s BUILD FAIL\n' "$want"; map_fail=$((map_fail + 1)); return
    fi
    for e in "$@"; do
        rom=$(find $SEARCH -type f -not -path "*/bios/*" -iname "*.$e" | head -1)
        [ -n "$rom" ] || continue
        got=$(RD_OUTDIR="$OUT" RD_FRAMES=2 timeout "$RUN_TIMEOUT" \
              ./build-host/retrods-host "$rom" 2>&1 \
              | sed -n 's/^retrods: core: \([^ ]*\).*/\1/p' | head -1)
        if [ "$got" = "$want" ]; then
            printf '%-18s OK    .%-5s %s\n' "$want" "$e" "$(basename "$rom")"
            map_pass=$((map_pass + 1))
        else
            printf '%-18s FAIL  .%-5s -> %s\n' "$want" "$e" "${got:-nothing}"
            map_fail=$((map_fail + 1))
        fi
    done
}

check_map cap32            dsk cpc
check_map fmsx             rom mx1
check_map quicknes         nes fds
check_map fceumm           nes
check_map gambatte         gb gbc
check_map smsplus          sms gg col
check_map vice_x64         crt d64
check_map beetle_vb        vb
check_map genesis_plus_gx  gen md
check_map atari800         atr xex
check_map beetle_wswan     ws wsc
check_map freeintv         int
check_map fuse             sna
check_map potator          sv
check_map stella2014       a26

echo
echo "passed $pass, failed $fail, no ROM $norom, needs a BIOS $needbios"
echo "mapping $map_pass ok, $map_fail wrong"
INNER
