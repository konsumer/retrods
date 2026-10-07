#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Generate build/gen/core_registry.inc from the core list.
#
# usage: gen-registry.sh <output> <name:ext1,ext2> ...
#
# Written as a script (rather than make's $(file ...)) because macOS ships
# GNU make 3.81, which predates the $(file) function.

set -eu

out="$1"
shift

: > "$out"

for spec in "$@"; do
    name="${spec%%:*}"
    exts="${spec#*:}"
    line="RD_ENTRY($name"
    old_ifs="$IFS"
    IFS=,
    for e in $exts; do
        line="$line, \"$e\""
    done
    IFS="$old_ifs"
    printf '%s\n' "$line)" >> "$out"
done
