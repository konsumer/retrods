#!/bin/sh
# SPDX-License-Identifier: Zlib
#
# Apply patches/*/<core>.patch to the vendored cores in third_party/.
#
# Cores are forked where a feature cannot work on the DS (see the note in each
# patch). Patches are kept as unified diffs and applied with `patch -p1` so that
# they also work on trees without git history. Re-running is safe.

set -eu

cd "$(dirname "$0")/.."

applied=0

for dir in third_party/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    [ -d "patches/$name" ] || continue

    for p in "patches/$name"/*.patch; do
        [ -f "$p" ] || continue
        pname=$(basename "$p")

        if patch -p1 -d "$dir" --forward --silent --dry-run < "$p" > /dev/null 2>&1; then
            patch -p1 -d "$dir" --forward --silent < "$p"
            echo "$name: applied $pname"
            applied=$((applied + 1))
        elif patch -p1 -d "$dir" --forward --silent --dry-run --reverse < "$p" > /dev/null 2>&1; then
            echo "$name: $pname already applied"
        else
            echo "$name: FAILED to apply $pname" >&2
            exit 1
        fi
    done
done

[ "$applied" -gt 0 ] && echo "applied $applied patch(es)"
exit 0

# Finally, generate anything a core's own build would have produced as a build
# input (config headers, generated lexers/parsers).
sh scripts/gen-core-inputs.sh
