#!/usr/bin/env python3
"""Generate cores/<name>.mk for a libretro core.

Sources, include paths and defines are taken from both of the ways a libretro
core describes its build:

  * its expanded make variables (SOURCES_C / SOURCES_CXX / INCFLAGS / CFLAGS),
  * the compile commands it would actually run (`make -n`).

Some cores only populate one of the two, so the union is used. Optional
features that pull in large bundled dependencies (CHD/CD image support) are
disabled via HAVE_CHD=0.
"""
import os
import re
import shlex
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HELPER = "/tmp/rd_probe.mk"

HELPER_TEXT = """\
rd_probe:
\t@echo "RD_SRCS_C=$(SOURCES_C)"
\t@echo "RD_SRCS_CXX=$(SOURCES_CXX)"
\t@echo "RD_INC=$(INCFLAGS)"
\t@echo "RD_DEF=$(DEFINES)"
\t@echo "RD_CFLAGS=$(CFLAGS)"
\t@echo "RD_CXXFLAGS=$(CXXFLAGS)"
"""

COMPILERS = ("cc", "gcc", "g++", "c++", "clang", "clang++")
SRC_EXT = (".c", ".cpp", ".cc", ".cxx", ".S", ".s", ".asm")
ASM_EXT = (".S", ".s", ".asm")
OK_SRC = re.compile(r"^-?D?[\w./+-]*\.(c|cpp|cc|cxx|S|s|asm)$")
OK_INC = re.compile(r"^-I[\w./+-]+$")
OK_DEF = re.compile(r"^-D[A-Za-z_][A-Za-z0-9_]*(=[A-Za-z0-9_]*)?$")


def run_make(core_dir, makefile, args, extra_target=None):
    cmd = ["make", "-f", makefile]
    if extra_target:
        cmd += ["-f", HELPER, extra_target]
    cmd += list(args)
    try:
        r = subprocess.run(cmd, cwd=core_dir, capture_output=True,
                           text=True, timeout=300)
    except subprocess.TimeoutExpired:
        return ""
    return r.stdout + r.stderr


def probe_vars(core_dir, makefile):
    with open(HELPER, "w") as f:
        f.write(HELPER_TEXT)
    out = run_make(core_dir, makefile, ["platform=unix", "HAVE_CHD=0"], "rd_probe")
    vals = {}
    for line in out.splitlines():
        m = re.match(r"^RD_([A-Z_]+)=(.*)$", line)
        if m:
            vals[m.group(1)] = m.group(2).strip()
    return vals


def probe_commands(core_dir, makefile):
    """Source files / flags from the actual compile commands."""
    out = run_make(core_dir, makefile, ["-n", "platform=unix", "HAVE_CHD=0"])
    srcs, incs, defs = [], [], []
    for line in out.splitlines():
        try:
            toks = shlex.split(line)
        except ValueError:
            continue
        if not toks or toks[0].split("/")[-1] not in COMPILERS:
            continue
        if "-c" not in toks:
            continue
        for t in toks[1:]:
            if OK_SRC.match(t) and not t.startswith("-"):
                srcs.append(t)
            elif OK_INC.match(t):
                incs.append(t)
            elif OK_DEF.match(t):
                defs.append(t)
    return srcs, incs, defs


def rewrite(tok, core_rel):
    if tok.startswith("-"):
        p = tok[2:]
        if p.startswith("/") or "$(" in p:
            return None
        return tok[:2] + (p if p.startswith(core_rel) else core_rel + "/" + p)
    if tok.startswith("/") or "$(" in tok:
        return None
    return core_rel + "/" + tok


def norm(p):
    """Collapse ./ and ../ so make's pattern rules can match."""
    return os.path.normpath(p)


def main():
    if len(sys.argv) < 4:
        print("usage: gen-core-mk.py <name> <repo-relative-core-dir> <exts...>")
        return 2
    name, core_rel, *exts = sys.argv[1:]
    core_abs = os.path.join(REPO, core_rel)

    makefile = None
    for mf in ("Makefile.libretro", "Makefile"):
        if os.path.exists(os.path.join(core_abs, mf)):
            makefile = mf
            break
    if not makefile:
        print(f"{name}: no makefile found", file=sys.stderr)
        return 1

    vals = probe_vars(core_abs, makefile)
    cmd_srcs, cmd_incs, cmd_defs = probe_commands(core_abs, makefile)

    srcs_c = [s for s in vals.get("SRCS_C", "").split()] + [s for s in cmd_srcs if s.endswith(".c")]
    srcs_cxx = [s for s in vals.get("SRCS_CXX", "").split()] + [s for s in cmd_srcs if not s.endswith(".c")]
    incs = vals.get("INC", "").split() + cmd_incs
    defs = (vals.get("DEF", "") + " " + vals.get("CFLAGS", "")).split() + cmd_defs

    def collect(items, kind):
        out, seen = [], set()
        for i in items:
            r = rewrite(i, core_rel)
            if not r:
                continue
            r = r[:2] + norm(r[2:]) if kind != "src" else norm(r)
            if r in seen:
                continue
            seen.add(r)
            out.append(r)
        return out

    src_lines = collect(srcs_c, "src")
    cxx_lines = [s for s in collect(srcs_cxx, "src")
                 if not s.endswith(".c") or s not in src_lines]
    src_lines = [s for s in src_lines if s not in cxx_lines]
    asm_lines = [s for s in src_lines if s.endswith(ASM_EXT)]
    src_lines = [s for s in src_lines if not s.endswith(ASM_EXT)]
    asm_lines += [s for s in cxx_lines if s.endswith(ASM_EXT)]
    cxx_lines = [s for s in cxx_lines if not s.endswith(ASM_EXT)]
    inc_lines = collect(incs, "inc")[:80]
    def_lines = sorted({d for d in defs if OK_DEF.match(d)})

    if not src_lines and not cxx_lines and not asm_lines:
        print(f"{name}: no sources found", file=sys.stderr)
        return 1

    parts = ["# SPDX-License-Identifier: Zlib",
             "#",
             f"# Generated from {core_rel}/{makefile} by scripts/gen-core-mk.py.",
             "# Edit the generator, not this file, then re-run it.",
             "",
             f"{name}_DIR := {core_rel}",
             f"{name}_EXTS := {' '.join(exts)}",
             ""]
    if src_lines:
        parts.append(f"{name}_SRCS := \\\n" + " \\\n".join("    " + s for s in src_lines))
        parts.append("")
    if asm_lines:
        parts.append(f"{name}_ASM_SRCS := \\\n" + " \\\n".join("    " + s for s in asm_lines))
        parts.append("")
    if cxx_lines:
        parts.append(f"{name}_CXX_SRCS := \\\n" + " \\\n".join("    " + s for s in cxx_lines))
        parts.append("")
    if def_lines:
        parts.append(f"{name}_DEFINES := \\\n    " + " ".join(def_lines))
        parts.append("")
    if inc_lines:
        parts.append(f"{name}_INCLUDES := \\\n" + " \\\n".join("    " + i for i in inc_lines))
        parts.append("")

    with open(os.path.join(REPO, "cores", f"{name}.mk"), "w") as f:
        f.write("\n".join(parts) + "\n")
    print(f"{name}: {len(src_lines)} C, {len(cxx_lines)} C++, {len(inc_lines)} includes, {len(def_lines)} defines")
    return 0


if __name__ == "__main__":
    sys.exit(main())
