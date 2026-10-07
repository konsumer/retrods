#!/usr/bin/env python3
# SPDX-License-Identifier: Zlib
"""Generate Pico Launcher file associations for the retrods apps.

The association map has to name every extension retrods can open and point it at
the app that carries that core, so it is derived from the same registry the
frontend compiles in (`make registry`) rather than maintained by hand.

Pico Launcher parses /_pico/settings.json into a fixed 2048-byte ArduinoJson
pool (JsonAppSettingsSerializer.thumb.cpp). Measured against that exact parser
(ArduinoJson 6.20.1, 32-bit ARM, 4-byte pointers, the DS ARM9's width), the pool
holds 63 associations of realistic path length -- and a file that overflows does
not merely lose its associations: Deserialize() fails and
JsonAppSettingsService then calls Save(), overwriting the user's file with
defaults. So the count is checked here.

Usage:
    scripts/gen-settings.py                       # write docs/settings-example.json
    scripts/gen-settings.py --apps-dir /apps      # where the .nds files will live
    scripts/gen-settings.py --output -            # print to stdout
"""

import argparse
import os
import re
import subprocess
import sys

# Pico Launcher's pool, and what a file costs in it. Measured against the real
# parser on 32-bit ARM (the ARM9's pointer width): 51 associations used 1648
# bytes and 60 used 1936, i.e. 32 bytes per association plus a 16-byte base --
# independent of the app path length, because ArduinoJson allocates in units of
# its largest node. That model puts the ceiling at 63, which is what the direct
# measurement found too.
POOL_BYTES = 2048
BYTES_PER_ENTRY = 32
BYTES_BASE = 16
# Warn before it gets tight; over POOL_BYTES the launcher would fail to parse and
# overwrite the file with defaults.
SAFE_BYTES = 1900

# Extensions that more than one core claims. The frontend resolves these by
# core order, but the launcher picks an app, so the choice is explicit here and
# can be overridden with --prefer ext=core.
DEFAULT_PREFERENCE = {
    "nes": "quicknes",             # over fceumm: 3.8 MiB smaller
    "fds": "quicknes",
    "sfc": "snes9x2005",           # over snes9x2002: better compatibility
    "smc": "snes9x2005",
    "gba": "beetle_gba",           # over gpsp: smaller
    "sgx": "beetle_supergrafx",    # dedicated core over beetle_pce_fast
    "d64": "vice_x64",             # C64 disks over cap32
    "tap": "vice_x64",
    "dsk": "cap32",                # CPC disks over fmsx
    "tap": "fuse",                 # the card this was built against is Spectrum-first
    "bin": "genesis_plus_gx",      # Mega Drive .bin dumps over Atari 8-bit
    "rom": "fmsx",                 # MSX .rom over Atari 8-bit
}

# Diagnostic core: nothing on a real SD card carries these extensions.
SKIP_CORES = {"testcore"}

# Extensions deliberately left unassociated. Two groups:
#
# 1. Ambiguous ones. `.bin` is claimed by the Atari 800, Genesis, Virtual Boy,
#    GBA, Coleco and Odyssey2 cores at once, and the card this was built against
#    normalises .bin to TI-99 (unsupported here), so an association would only
#    ever mis-open those files. Rename them to the real extension.
# 2. Rare formats, because the launcher's pool is finite (about 63 associations
#    of this length) and the common extension for each system already covers it:
#    the Neo Geo Pocket's .ngp/.ngc cover .ngpc/.npc, MSX's .dsk/.rom cover .fdi
#    and .mx2, the SNES's .smc/.sfc cover .fig, and so on. `--keep ext` puts any
#    of these back and `--skip ext` takes more out.
SKIP_EXTS = {
    "bin",
    "p00", "unf", "unif", "dmg", "fig", "ngpc", "npc", "szx", "fdi",
}


def run_registry(repo: str) -> dict:
    """Ask make for the resolved core -> extensions table."""
    cores = sorted(
        os.path.splitext(os.path.basename(p))[0]
        for p in os.listdir(os.path.join(repo, "cores"))
        if p.endswith(".mk") and not p.endswith(".extra.mk")
    )
    out = subprocess.run(
        ["make", "-f", "Makefile.host", "CORES=" + " ".join(cores), "registry"],
        cwd=repo, capture_output=True, text=True, check=True,
    ).stdout

    table = {}
    for line in out.splitlines():
        m = re.match(r'RD_ENTRY\(([\w.+-]+),?\s*(.*)\)\s*$', line)
        if not m:
            continue
        table[m.group(1)] = re.findall(r'"([^"]*)"', m.group(2))
    if not table:
        sys.exit("gen-settings: `make registry` produced no cores")
    return table


def build_map(table: dict, preference: dict, apps_dir: str):
    """extension -> app path, plus the conflicts that a preference resolved."""
    chosen, conflicts = {}, {}
    for core, exts in table.items():
        if core in SKIP_CORES:
            continue
        app = f"{apps_dir.rstrip('/')}/retrods-{core}.nds"
        for ext in exts:
            if ext in SKIP_EXTS:
                continue
            chosen.setdefault(ext, []).append(core)

    result = {}
    for ext, cores in sorted(chosen.items()):
        if len(cores) == 1:
            winner = cores[0]
        else:
            conflicts[ext] = cores
            winner = preference.get(ext)
            if winner not in cores:
                winner = cores[0]
        result[ext] = f"{apps_dir.rstrip('/')}/retrods-{winner}.nds"
    return result, conflicts


def main() -> int:
    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--apps-dir", default="/apps",
                    help="directory the .nds files are copied to (default: /apps)")
    ap.add_argument("--output", default=os.path.join("docs", "settings-example.json"),
                    help="output file, or - for stdout")
    ap.add_argument("--skip", action="append", default=[], metavar="EXT",
                    help="leave an extension unassociated (repeatable)")
    ap.add_argument("--keep", action="append", default=[], metavar="EXT",
                    help="associate an extension that is skipped by default")
    ap.add_argument("--prefer", action="append", default=[], metavar="EXT=CORE",
                    help="override which core an ambiguous extension maps to")
    args = ap.parse_args()

    preference = dict(DEFAULT_PREFERENCE)
    for item in args.prefer:
        if "=" not in item:
            ap.error(f"--prefer wants ext=core, got {item!r}")
        ext, core = item.split("=", 1)
        preference[ext.strip().lower()] = core.strip()

    for ext in args.skip:
        SKIP_EXTS.add(ext.strip().lower())
    for ext in args.keep:
        SKIP_EXTS.discard(ext.strip().lower())

    table = run_registry(repo)
    assoc, conflicts = build_map(table, preference, args.apps_dir)

    cost = BYTES_BASE + BYTES_PER_ENTRY * len(assoc)
    if cost > POOL_BYTES:
        sys.exit(f"gen-settings: {len(assoc)} associations need about {cost} bytes of "
                 f"Pico Launcher's {POOL_BYTES}-byte pool; over that it fails to parse "
                 f"and overwrites settings.json with defaults. Drop extensions with "
                 f"--skip or add cores to a second build")

    text = "{\n  \"fileAssociations\": {\n"
    items = sorted(assoc.items())
    width = max(len(f'"{e}"') for e, _ in items)
    for i, (ext, app) in enumerate(items):
        comma = "," if i + 1 < len(items) else ""
        text += f'    {f"\"{ext}\"".ljust(width)}: {{ "appPath": "{app}" }}{comma}\n'
    text += "  }\n}\n"

    if args.output == "-":
        sys.stdout.write(text)
    else:
        path = args.output if os.path.isabs(args.output) \
            else os.path.join(repo, args.output)
        with open(path, "w") as fh:
            fh.write(text)
        print(f"wrote {os.path.relpath(path, repo)}")

    if conflicts:
        print(f"\n{len(conflicts)} extension(s) are claimed by more than one core:")
        for ext, cores in sorted(conflicts.items()):
            print(f"  .{ext:<5} {' | '.join(cores)}  ->  {assoc[ext].split('/')[-1]}")
        print("  override with --prefer ext=core")

    used = len(assoc)
    note = "ok" if cost <= SAFE_BYTES else "close to the limit"
    print(f"\n{used} associations, about {cost} of Pico Launcher's {POOL_BYTES} pool "
          f"bytes ({note})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
