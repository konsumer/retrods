#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Generate the files that some cores' own build systems produce as *inputs* to
# compilation: config headers copied from templates, version strings, and
# lexer/parser sources. retrods does not run a core's makefile, so nothing would
# generate them, and a build then fails in confusing ways (a missing config.h, or
# an undefined yylex()).
#
# Idempotent, and derived only from the pinned checkout, so it is safe to re-run.
# Called from apply-patches.sh, which fetch-cores.sh runs.

set -eu
cd "$(dirname "$0")/.."

fuse=third_party/fuse-libretro
if [ -d "$fuse" ]; then
    # Makefile.libretro: fuse/config.h and libspectrum/config.h are copies.
    [ -f "$fuse/fuse/config.h" ] || cp "$fuse/src/config_fuse.h" "$fuse/fuse/config.h"
    [ -f "$fuse/libspectrum/config.h" ] || \
        cp "$fuse/src/config_libspectrum.h" "$fuse/libspectrum/config.h"

    # Makefile.libretro: src/version.c from the template with the commit hash.
    if [ ! -s "$fuse/src/version.c" ]; then
        hash=$(git -C "$fuse" rev-parse HEAD 2>/dev/null | tr -d '\n') || hash=unknown
        sed "s/HASH/${hash:-unknown}/g" "$fuse/etc/version.c.templ" > "$fuse/src/version.c"
    fi

    # fuse/debugger/commandl.c ships as an empty placeholder and commandy.c as a
    # stale bison output; upstream's build regenerates both with the implicit
    # make rules. They only work as a matched pair, so regenerate both from the
    # .l/.y sources with the tools in the image (bison and flex).
    dbg=$fuse/fuse/debugger
    if [ ! -s "$dbg/commandl.c" ]; then
        if command -v flex >/dev/null 2>&1 && command -v bison >/dev/null 2>&1; then
            flex  -o "$dbg/commandl.c" "$dbg/commandl.l"
            bison -d -o "$dbg/commandy.c" "$dbg/commandy.y"
        else
            echo "gen-core-inputs: flex/bison missing, so fuse's parser cannot be" >&2
            echo "  generated; build inside the container (scripts/build.sh)." >&2
        fi
    fi
fi
