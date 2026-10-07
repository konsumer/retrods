# retrods

A multi-system **libretro frontend for Nintendo DS(i)**, driven entirely by
command-line arguments. It is designed to be launched by
[Pico Launcher](https://github.com/LNH-team/pico-launcher) (the menu that ships
on [DSpico](https://www.lnh-team.org/) flashcarts) via *file associations*, so
that selecting a `.nes` / `.sms` / `.gb` file opens the right emulator core
immediately. There is no built-in menu, file browser or settings UI.

```
                        file association (one per extension)
Pico Launcher  ---------------------------------------->  retrods-<core>.nds
      |                                                           |
      |  argv[1] = the ROM path                                   | one core,
      v                                                           v linked in
  DSpico SD  -------------------------------------------->   libretro core
```

A build carries **one core**, because every core is resident in RAM at once and a
DS has 4 MiB. `scripts/build-apps.sh` therefore emits one small `.nds` per core
(`apps/retrods-<core>.nds`), and Pico Launcher's file associations decide which
one opens a given ROM.

## Launching

Opening a file with a mapped extension is a two-step hand-off, and both halves
are readable in the sources:

```c
// pico-launcher, CustomFileType::TrySetLaunchParameters (a file association)
StringUtil::Copy(launchParameters->romPath, _fileAssociation->applicationPath, ...); // the .nds
StringUtil::Copy(launchParameters->arguments, filePath, ...);                        // the ROM
```

Pico Loader (`NdsLoader::InsertArgv`) writes those into the homebrew argv
structure at `0x02FFFE70` (magic `0x5f617267`) as `<app path>\0<rom path>\0`, and
libnds's `build_argv()` splits that into `argc`/`argv` for `main()`:

| argv | value                            |
| ---- | -------------------------------- |
| `0`  | `fat:/apps/retrods-quicknes.nds` |
| `1`  | `/Roms/Sonic The Hedgehog.sms`   |

retrods uses `argv[1]` as the ROM path and picks its core from the file
extension. `--core=<name>` overrides the mapping, which is only interesting in a
multi-core build and in the test harness.

`argv[0]` is the app's own path, which is where the firmware directory comes
from: `retrods-o2em.nds` in `/apps` looks for `/apps/bios/o2rom.bin` and
`/apps/bios/voice/*.WAV`. There is nothing to configure — see
[docs/BIOS.md](docs/BIOS.md).

### File associations

`/_pico/settings.json` maps each extension to the app that should open it. That
list is **generated from the registry the frontend compiles in**, so it cannot
drift out of step with the cores:

```sh
./scripts/gen-settings.py                      # -> docs/settings-example.json
./scripts/gen-settings.py --apps-dir /emu/ds   # match where you copy the apps
```

Extensions that more than one core claims (`.nes`, `.dsk`, `.rom`, …) are
printed with the core chosen for them; `--prefer ext=core` changes that, and
`--skip ext` leaves one unassociated. `.bin` is skipped by default: six cores
claim it and the card this was built against normalises it to TI-99, which has
no core here, so any association would only mis-open those files.

The pool is a real budget, not a formality — the generator reports what the file
costs (the current 60 associations come to about 1936 of the 2048 bytes, which
matches what the launcher's own parser reports byte for byte).

Pico Launcher parses this file into a fixed **2048-byte** ArduinoJson pool
(`JsonAppSettingsSerializer.thumb.cpp`). Measured with that exact parser
(ArduinoJson 6.20.1 on 32-bit ARM, the ARM9's pointer width) the pool holds **63
associations** — enough for every extension here, but not much more. Overrun it
and the failure is not graceful: `deserializeJson` returns `NoMemory`,
`Deserialize` reports failure, and `JsonAppSettingsService` then calls `Save()`,
**overwriting your settings with defaults**. Every key in the file is parsed into
that pool, so keep it to `fileAssociations` — a long comment costs as much as an
association does. `scripts/gen-settings.py` refuses to emit a file that would
not fit.

## Two ways to use the cores

**One app per core (recommended).** The multi-core binary has to fit every
selected core in RAM at once, which is why a DS build can only hold two or three.
Instead, build a tiny single-core app per emulator and let Pico Launcher's file
associations pick between them:

```sh
./scripts/build-apps.sh          # -> apps/retrods-<core>.nds, one per core
```

Each app is the same small libretro host plus exactly one core, so the RAM budget
applies per core rather than to the sum. The script tries DS mode first and falls
back to DSi mode when a core does not fit 4 MiB:

| | cores | note |
| --- | --- | --- |
| DS mode (run on any DS/DSi/3DS) | **24** | `beetle_pce_fast`, `cap32`, `potator`, `gambatte`, `quicknes`, `atari800`, `smsplus`, … |
| DSi mode only | 6 | `fuse`, `genesis_plus_gx`, `fceumm`, `vice_x64`, `beetle_supergrafx`, `vecx` |

Which side a core lands on is decided by the linker, not by the size on the
card — these are compressed. A core has to fit 4 MiB *uncompressed* to run on a
plain DS, so `vecx` is DSi-only despite its 0.2 MiB `.nds`.

So a DS can hold essentially every core here — just not all in one binary.
`docs/settings-example.json` maps every supported extension to the matching app.

**One multi-core binary.** `make CORES="..."` still produces a single
`retrods.nds` holding several cores, which is convenient if you only care about a
couple of systems and want one file.

## Cores

29 emulation cores are wired up, plus a diagnostic core. A core's extensions
live with its build rules in `cores/<name>.mk` (overridable per core in
`cores/<name>.extra.mk`), and what each core actually claims is what
`make registry` reports and `scripts/gen-settings.py` turns into launcher
associations.

| Core | Systems | Extensions | On-card `.nds` |
| ---- | ------- | ---------- | ------------- |
| `smsplus` | Master System, Game Gear, SG-1000, ColecoVision | `sms gg sg col mv` | 0.2 MiB |
| `quicknes` | NES / Famicom | `nes fds` | 0.9 MiB |
| `fceumm` | NES / Famicom (more mappers, much bigger) | `nes fds unf unif` | 2.4 MiB |
| `gambatte` | Game Boy / Game Boy Color | `gb gbc dmg` | 1.4 MiB |
| `beetle_gba` | Game Boy Advance | `gba` | 0.6 MiB |
| `gpsp` | Game Boy Advance (HLE BIOS, faster) | `gba` | 0.5 MiB |
| `snes9x2002` | Super Nintendo | `sfc smc swc fig` | 0.5 MiB |
| `snes9x2005` | Super Nintendo (better compatibility) | `sfc smc swc fig` | 0.5 MiB |
| `genesis_plus_gx` | Sega Mega Drive / Genesis | `gen md bin smd` | 4.6 MiB |
| `beetle_vb` | Virtual Boy | `vb vboy` | 0.2 MiB |
| `stella2014` | Atari 2600 | `a26` | 1.3 MiB |
| `prosystem` | Atari 7800 | `a78` | 0.3 MiB |
| `handy` | Atari Lynx | `lnx` | 0.6 MiB |
| `o2em` | Magnavox Odyssey² | `o2` | 0.4 MiB |
| `freeintv` | Intellivision | `int` | 0.7 MiB |
| `beetle_ngp` | Neo Geo Pocket / Color | `ngp ngc ngpc npc` | 0.3 MiB |
| `beetle_wswan` | WonderSwan / Color | `ws wsc pc2` | 0.6 MiB |
| `beetle_pce_fast` | PC Engine / TurboGrafx (HuCard) | `pce` | 2.0 MiB |
| `beetle_supergrafx` | PC Engine SuperGrafx | `pce sgx` | 1.7 MiB |
| `cap32` | Amstrad CPC | `dsk cpc tap sna` | 1.5 MiB |
| `vecx` | Vectrex | `vec` | 0.2 MiB |
| `pokemini` | Pokémon Mini | `min` | 0.4 MiB |
| `freechaf` | Fairchild Channel F | `chf` | 0.2 MiB |
| `fmsx` | MSX | `rom mx1 mx2 dsk fdi cas` | 0.3 MiB |
| `atari800` | Atari 8-bit (800/XL/XE) and 5200 | `atr xex car bin rom a52 atx` | 0.7 MiB |
| `vice_x64` | Commodore 64 | `crt d64 t64 p00 prg tap` | 2.0 MiB |
| `gw` | Game & Watch | `mgw gw` | 0.5 MiB |
| `testcore` | diagnostic pattern + tone (no ROM) | `rdt testrd` | 0.1 MiB |

**All 29 emulation cores have been run** (see `docs/TESTING.md` for the
matrix); the last two needed content rather than code:

* **`gw` (Game & Watch)** takes `.mgw` files, which it runs given real ones
  (Donkey Kong Circus renders 128x128).
* **`o2em` (Odyssey²)** needs the copyrighted 1 KiB `o2rom.bin` in the system
  directory. Without it the core says so rather than failing silently:

```
retrods: [O2EM]: Error loading BIOS ROM (<system-dir>/o2rom.bin).
retrods: core rejected content: /path/to/game.o2
```

`tests/run-roms.sh` takes any number of ROM directories, and reports a missing
BIOS as its own category so an absent system file is never counted as a core
failure. It also *fails* a BIOS-dependent core that silently does nothing.

`vice_x64` produces audio: a 300-frame run of Beamrider (a cartridge that
starts) yields 287264 samples peaking at 16020, which the test suite asserts so a
regression cannot pass as "video only".

`beetle_vb` was checked against a full 27-ROM Virtual Boy collection: every
cartridge boots and renders, including Virtual Boy Wario Land, Red Alarm,
Teleroboxer, Mario Clash, Jack Bros, Vertical Force and Galactic Pinball. It
renders the console's four-shade red palette directly — 384x224, 1744 non-black
pixels in a Wario Land title frame.

Several systems have two cores, and the first core listed for an extension in
`CORES` wins: prefer `quicknes` over `fceumm` for NES, `beetle_gba` over `gpsp`
for size, and `snes9x2005` over `snes9x2002` for compatibility. The same choices
are made for the launcher associations by `scripts/gen-settings.py`.

The two GBA cores need a real `gba_bios.bin`, except that `gpsp` ships a
high-level-emulation BIOS and runs without one.

### You cannot ship all of them at once

Every core is resident in RAM simultaneously, and a DS has **4 MiB** (DSi mode:
16 MiB). The sizes above add up to well over the DS budget — `vecx` alone is
larger than the whole machine — so **the core set is a build-time choice**:

```sh
make    # default: testcore smsplus quicknes beetle_gba pokemini   (~3.4 MiB)
make CORES="testcore smsplus gambatte beetle_gba pokemini"         # swap NES for GB/GBC
make CORES="testcore smsplus snes9x2005 beetle_gba pokemini"       # swap NES for SNES
make DSI=1 CORES="testcore smsplus quicknes beetle_gba gambatte snes9x2005 pokemini freechaf"  # DSi, 6.2 MiB
make CORES="testcore atari800"                                     # Atari 8-bit on a DS
```

The linker enforces the budget and fails with ``region `ewram' overflowed``.
Roughly: a DS build holds ~3.1 MiB of cores, a DSi-mode build ~14 MiB.

## Building

The toolchain is [BlocksDS](https://blocksds.skylyrac.net/) — the same modern
DS SDK that Pico Loader and Pico Launcher themselves use — run through Docker,
so no host setup is required.

```sh
# 1. get the cores (pinned commits) and apply local patches
./scripts/fetch-cores.sh

# 2. build the app per core (what you actually deploy)
./scripts/build-apps.sh             # -> apps/retrods-<core>.nds
./scripts/gen-settings.py           # -> the associations that launch them

# or one multi-core binary
./scripts/build.sh                  # -> retrods.nds      (DS mode)
./scripts/build.sh dsi              # -> retrods-dsi.nds  (DSi memory map)
```

### Deployment

```
SD card root
├── _pico/
│   ├── settings.json      # associations, from scripts/gen-settings.py
│   └── (Pico Loader files, themes)
├── _picoboot.nds          # Pico Launcher
├── apps/                  # one app per core, from scripts/build-apps.sh
│   ├── retrods-quicknes.nds
│   ├── retrods-gambatte.nds
│   ├── ...                # 30 apps, 28 MiB total
│   ├── bios/              # firmware, found relative to the .nds files
│   │   ├── o2rom.bin
│   │   └── voice/E480.WAV ...
│   └── saves/
└── Roms/
    └── Super Mario Bros.nes
```

```sh
./scripts/build-apps.sh                 # -> apps/ (apps + bios + saves)
./scripts/gen-settings.py               # -> docs/settings-example.json
# copy the whole apps/ directory to <sd>/apps, and the generated file to
# <sd>/_pico/settings.json
```

### BIOS / firmware

Firmware lives in **`apps/bios`**, next to the `.nds` files. The frontend derives
the system and save directories from `argv[0]` — the path Pico Launcher launches
the app with — so nothing is hardcoded and one directory is the whole
deployment. `scripts/build-apps.sh` never clears its output directory, so
`apps/bios` and `apps/saves` survive a rebuild:

```sh
./scripts/build-apps.sh                 # -> apps/ (28 apps)
cp -R apps/. /Volumes/<card>/apps/      # apps, firmware and saves together
```

Only one file is genuinely required: `o2rom.bin` for `o2em`, which refuses
content without it and names the path it looked in. Everything else is
optional — `gba_bios.bin`, `gbc_bios.bin`, `disksys.rom`, the atari800 OS ROMs,
`exec.bin`/`grom.bin`, `syscard3.pce`, the `o2em` `voice/` samples, JiffyDOS.

See **[docs/BIOS.md](docs/BIOS.md)** for the full table: every filename verified
against the vendored core that reads it, which are required, which cores need
nothing (including `vice_x64`, measured with an empty directory), and where the
files come from. None of them are included — they keep their own copyright.

## Host test harness

The frontend and the cores are portable C/C++, so `Makefile.host` builds the
same `src/` and core sources for the dev machine and runs them natively, with a
headless backend that dumps frames as PPM and audio as WAV:

```sh
./tests/run-host.sh
```

`tests/run-roms.sh <rom-dir> [more dirs…]` is the fuller one: it runs one real
ROM per core, then rebuilds the host with a *single* core and opens a matching
ROM **without** `--core`, which is the path Pico Launcher uses and the only way
to catch a core that fails to claim an extension it should (`cap32` used to omit
`.dsk`, so CPC disk images went to `fmsx`).

Both run inside the build container, because the host build needs the same
`objcopy`-based symbol renaming as the DS build. `scripts/gen-test-rom.py`
generates trivial homebrew ROMs for NES, Game Boy, SNES, Master System, GBA,
Vectrex, Virtual Boy, Channel F and Odyssey2, so cores whose content is missing
can still be smoke-tested without copyrighted files. See
`docs/TESTING.md`.

## Controls

| DS            | libretro                        |
| ------------- | ------------------------------- |
| D-Pad         | `JOYPAD_UP/DOWN/LEFT/RIGHT`     |
| A / B         | `JOYPAD_A` / `JOYPAD_B`         |
| X / Y         | `JOYPAD_X` / `JOYPAD_Y`         |
| L / R         | `JOYPAD_L` / `JOYPAD_R`         |
| START / SELECT| `JOYPAD_START` / `JOYPAD_SELECT`|

Held together with **L+R** so a game cannot trigger one by accident:

| Combo | Action |
| ----- | ------ |
| L+R+START | save state to `<rom>.state` |
| L+R+SELECT | load that state |
| L+R+X | screenshot to `<rom>_<frame>.<ppm or bmp>` |
| L+R+A | fast-forward while held |
| L+R+START+SELECT | quit to the loader |

Every core implements libretro's save-state interface, so this works for all of
them; the state is one file per game next to the ROM, and the message about it
appears on the DS's bottom screen. SRAM is written next to the ROM as
`<rom>.srm` and reloaded on the next run.

## Acceleration

| Mechanism | Status |
| --------- | ------ |
| **DSi RAM map** (15 MiB) | used: `make DSI=1` links with `dsi_arm9.specs`, so the core set and ROM buffer may exceed the 4 MiB DS limit **when the console runs the ROM in DSi mode** |
| **DSi mode** (ARM9 @ 133 MHz, 16 MiB at runtime) | *not* enabled by the executable — the console/loader decides this. Not verified here; `dsi_arm9.specs` only changes the linker's memory map, it does not clock the CPU |
| **2D engine hardware scaling** | not used yet: the core's frame is scaled on the CPU into the bitmap background. The DS bitmap BG supports affine scaling (`REG_BGxPA`…), which is the planned optimisation |
| **ARM7** (33 MHz) | used: audio playback and keypad handling run through the ARM7 (libnds sound driver) |
| **RP2040 on the DSpico cartridge** | exposes the SD card and USB over the cartridge bus; it is not a general-purpose accelerator for DS code |
| GPU compute / DSP | none available on the DS |

There is no general-purpose GPU compute on the DS, so "acceleration" here means
the DSi's faster clock and extra RAM (both gated by booting in DSi mode), and
offloading audio to the ARM7.

## Adding a core

```sh
python3 scripts/gen-core-mk.py <name> third_party/<repo> <ext...>
make CORES="testcore smsplus <name>"
```

The generator asks the core's own makefile for its source list, include paths
and defines (union of `make -n` and its expanded variables) and writes
`cores/<name>.mk`. Hand-written tweaks belong in `cores/<name>.extra.mk`, which
is never regenerated — that is where a core's unsupported features get switched
off (see `cores/vecx.extra.mk`, `cores/gambatte.extra.mk`).

## Forking cores

Where a feature simply cannot work on the DS, the core is patched rather than
left broken. Patches live in `patches/<core>/NNN-*.patch`, are plain unified
diffs, and are applied by `scripts/apply-patches.sh` (called from
`fetch-cores.sh`, safe to re-run):

```
patches/gambatte-libretro/0001-netplay-optional.patch
    guards the file-scope `NetSerial` instance with HAVE_NETWORK so netplay can
    be compiled out (it needs BSD sockets the DS does not have)

patches/libretro-atari800/0001-sysrom-sys-types.patch
    sysrom.c includes <dirent.h> without <sys/types.h>; glibc pulls off_t in
    transitively, newlib does not

patches/vice-libretro/0001-disable-resid.patch
    include/config.h turns on both reSID and FASTSID, and VICE's resolver picks
    reSID. reSID's 6581 filter tables are 21 MiB of .bss, so the C64 core drops
    to FASTSID instead (6.1 MiB rather than 27 MiB)

patches/vice-libretro/0002-sid-engine-fallback.patch
    with reSID compiled out (0001) but the SID-engine resource still defaulting
    to it, VICE picked its **dummy** engine and reported success, which is what
    made C64 audio silent. `sid_sound_machine_set_engine_hooks()` now tracks
    whether an engine was actually matched and falls back to FASTSID, and
    `set_sid_engine()` does the same for an explicit request

patches/fmsx-libretro/0001-inline-not-clobbered.patch
    MSX.h and Z80.c `#undef INLINE` and redefine it as `static inline`, which
    turns libretro-common's `static INLINE` into `static static inline`

patches/Genesis-Plus-GX/0001-shrink-cd-cart-area.patch
    cd_cart_t::area is 8 MB + 64 KB and sits inside the `external_t` union, so
    every build pays for it although only Sega CD cartridges use it

patches/libretro-common/0001-inline-specifier.patch
    libretro-common's headers write `static INLINE ...`, which needs INLINE to be
    a *bare* specifier. Cores redefine INLINE freely, so those headers now use
    `static __inline__` directly and no longer care what a core does with it
    (this is what several cores needed; see fmsx and Genesis below)
```

### Core options

Cores register their options during init and read them back with
`RETRO_ENVIRONMENT_GET_VARIABLE`. Answering that matters: a frontend that cannot
leaves some cores on a disabled path — VICE zeroes its resources, and
libretro-cap32 never calls `video_setup()`, so `retro_video.rgb2color` stays NULL
and its UI crashes on the first draw.

Two things make this subtle, and both cost a debugging round:

* **The tables must be copied when they are handed over.** quicknes passes an
  array that lives on its stack; keeping the pointer and reading it later walks
  reused memory. The options are now snapshotted at registration.
* **Only the long-stable interfaces are parsed** — `SET_VARIABLES` (16) and
  `SET_CORE_OPTIONS`/`INTL` (53/54). The V2 tables are accepted but not read: a
  core built against an older `libretro.h` can hand over a payload whose layout
  does not match our structs.

A legacy variable's value is `"Description; default|other"`, so the default is
the first item; table-driven options already carry one value per entry.

Prefer disabling a feature over faking it: a patch should remove a code path
that cannot work, not stub it into pretending to work. Where a feature is
optional and already `#ifdef`-guarded, switch it off with a
`cores/<name>.extra.mk` define override instead of patching.

### Why the symbols get renamed

Cores all export the same `retro_*` API, and they also vendor and duplicate a
lot of helper code (mednafen's `Blip_Buffer`, `libretro-core-options` tables,
`MDFN*` utilities…). Linking more than one core therefore collides on both.

`core_rules.mk` handles this per core: compile plainly → merge with `ld -r` →
`objcopy --redefine-syms` so every global symbol it defines becomes
`<core>_<symbol>`. It is done at the object level rather than with a generated
`-D` header because C++ mangled names never appear in the source, so the
preprocessor can never see them.

`libretro-common` is the exception: it is compiled once from
`third_party/libretro-common` and shared, so all cores agree on one copy
(`LC_SRCS` / `LC_EXTRA` / `LC_EXCLUDE` in `common.mk`).

### Known blockers

* **`fceumm` (NES)** is too big for a 4 MiB DS; use `quicknes` there instead.
* **`beetle_gba` needs a `gba_bios.bin`** in the system directory
  (`fat:/retrods/system`); `gpsp` runs without one.
* **`picodrive` (Mega Drive)** extracts no usable source list with the current
  generator, and 68k + Mega Drive at 67 MHz would be a stretch anyway.
* **`81` (ZX81) / `gearboy` (GB) / `sameboy` (GB)** need generated `config.h` /
  version files or SDL shims that their makefiles normally produce with
  configure-style steps; all are candidates for a patch. `fuse` needed the same
  treatment and is now in: `scripts/gen-core-inputs.sh` produces the two config
  headers, the version string and the flex-generated lexer that its build creates
  as *inputs*.
* **`genesis_plus_gx` (Mega Drive)** is DSi-only, because `external_t ext` is a
  union whose Sega CD half is charged to every build. Three things were needed to
  get it this far — the INLINE fix above, dropping the CHD deps (41 MB -> 17.8 MB)
  and `patches/Genesis-Plus-GX/` shrinking `cd_cart_t::area` from 8 MB (17.8 MB
  -> 13.8 MB). Dropping CD support from the union entirely would take it further.
* **`gw` (Game & Watch)** needs real `.mgw` ROMs. A `.mgw` is just a tar v7
  archive, but a synthetic one parses and then spins the emulated CPU forever,
  so it is not a format a test ROM can fake.
* **Some C64 cartridges never start.** The first `.crt` alphabetically in a
  test collection boots, fills the screen and then stalls without touching the
  SID; others (Beamrider, tested) run and play. That is the cartridge, not the
  core: the same build renders real audio (peak 16020) for a cart that starts.
* **`beetle_pce_fast` CD games** are unsupported: CHD support is built with
  `HAVE_CHD=0`, so only HuCard images work.
* **`vecx`, `beetle_supergrafx` and `cap32`** are large; they fit only in a
  DSi-mode build or a DS build with few other cores.
* **Systems with no libretro core at all**: the CoCo/Dragon/MC-10 and the
  TI-99/4A. Two ports were started as separate projects, because no libretro core
  exists for either and both are ports of desktop emulators rather than wrappers:

  | project | upstream | state |
  | ------- | -------- | ----- |
  | `~/Desktop/ti99-libretro` | ti99sim (C++, GPL-2) | **the libretro core builds** (`make libretro` → 250 KB `.so`), loads `994aROM.bin`/`994aGROM.bin`, runs frames and renders all four VDP modes. **The frame is black**: the CPU does not touch the VDP, which is the one open bug. `tools/bootcheck` reproduces it in 30 s (`TI99_DEBUG=1` prints mode and R0-R7 per frame). CI builds and attaches on release. |
  | `~/Desktop/xroar-libretro` | XRoar (C, GPL-3) | vendored and pinned, CI valid, port plan in its README. **No glue written yet.** Covers CoCo, Dragon *and* MC-10 — three systems for one port. |

  Neither is wired into retrods yet. When one works the integration is the same
  path every other core took: a pinned `scripts/fetch-cores.sh` line,
  `scripts/gen-core-mk.py`, a `cores/<name>.extra.mk`, and `patches/<core>/` for
  anything DS-specific. On a DS these will need patches the desktop build does
  not: XRoar's 6809 core and ti99sim's TMS9900 both assume a host's `int` width
  in places.

* **`.dsk`, `.bin` and `.rom` are ambiguous** — CPC disks vs MSX disks, Mega
  Drive vs Atari 8-bit `.bin`, MSX vs Atari 8-bit `.rom`. Both cores claim the
  extension where that is right, the order in `CORES` decides at runtime, and
  `scripts/gen-settings.py --prefer` decides for the launcher.

## Layout

```
src/
  main.c            argv parsing, core selection
  libretro_host.c   libretro callbacks, run loop, SRAM
  registry.c        generated dispatch table (build/gen/core_registry.inc)
  core.h            core descriptor
  platform.h        platform interface
  nds/              DS backend (framebuffer, sound, keypad, libfat)
  posix/            host-test backend (PPM/WAV dumps)
  cores/testcore.c  diagnostic core
cores/<name>.mk       per-core source list / flags (generated)
cores/<name>.extra.mk hand-written overrides, never regenerated
patches/<core>/       local forks of cores, as unified diffs
common.mk             core list, shared libretro-common, registry generation
core_rules.mk         per-core compile + symbol renaming rules
Makefile              DS build (BlocksDS)
Makefile.host         host test build
scripts/              fetch-cores, apply-patches, build, build-apps,
                      gen-core-mk, gen-registry, gen-settings, gen-test-rom
tests/run-host.sh     end-to-end host smoke test
tests/run-roms.sh     per-core ROM matrix + extension -> core mapping check
docs/TESTING.md       what is and is not verified, and how to test
docs/BIOS.md          firmware layout, per-core filenames, where to get them
```

## Licence

Zlib (see [LICENSE](LICENSE)), matching the DS homebrew ecosystem; every source
file carries the SPDX tag. The cores are not vendored here — `scripts/fetch-cores.sh`
clones them from their own repositories at pinned commits — and they keep their
own licences, which are not all as permissive: smsplus-gx is non-commercial, so
check before redistributing a ROM built with it.
