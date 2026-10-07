# Testing

## Verification status

| Layer | How it is verified | Status |
| ----- | ------------------ | ------ |
| Frontend logic (argv, registry, libretro callbacks, run loop, SRAM) | `tests/run-host.sh` builds the same sources for the host and runs real cores natively | verified |
| Core integration | the host build compiles and links **all 27 cores** together | verified |
| Core execution | **all 28 emulators** run content and produce video + audio: 24 on real ROMs, `vecx`, `freechaf` and `o2em` on generated ones | verified |
| Extension -> core mapping | `tests/run-roms.sh` rebuilds the host with a *single* core and opens a matching ROM without `--core` — the path Pico Launcher uses. 19 pairs asserted | verified |
| Launcher associations | `scripts/gen-settings.py` derives them from `make registry`; the output was parsed with Pico Launcher's own parser (ArduinoJson 6.20.1, 32-bit ARM, 2048-byte pool) | verified |
| Virtual Boy | all **27** ROMs of a retail collection boot and render; Virtual Boy Wario Land draws 1744 non-black pixels of a 384x224 frame | verified |
| DS build | `scripts/build.sh` produces a valid `.nds`, header checked with `ndstool -i`, fits the RAM budget | verified |
| DS boot: display, sound, libfat/DLDI, argv plumbing, core registry | `retrods.nds` booted in melonDS; the app renders its console output and reaches its hold/usage path | verified |
| Core execution on the DS | needs the loader argv or DSi-mode; not done | **not verified** |
| DSi mode (133 MHz / 16 MiB) | needs DSi BIOS/firmware and DSi-mode boot | **not verified** |
| Real hardware (DSpico) | needs a DS/DSi | **not verified** |
| `cap32` (Amstrad CPC) | fixed by the core-options work: `video_setup()` now runs, so `retro_video.rgb2color` is valid | verified |
| `o2em` (Odyssey²) | with its 1 KiB `o2rom.bin` in the system directory it loads content and renders 340x250 @ 60 fps. Without the BIOS it says so instead of failing silently, and the matrix reports that as "needs a system BIOS" rather than a failure | verified |
| C64 audio | `vice_x64` renders video (384x272 @ 50 fps) **and audio**: 287264 samples, peak 16020, from a 300-frame run of Beamrider. The matrix asserts a non-silent peak for this core | verified |

Outside the verified rows only `testcore` remains: it is a diagnostic and
takes no ROM.

One caveat on the C64 row: some cartridges never start. The first `.crt`
alphabetically in the collection under test boots to the KERNAL screen, then
runs a stalled program that leaves the SID alone — video comes out, audio does
not, and it looks exactly like a broken core. `try` therefore takes a per-core
preferred ROM (`preferred_rom()` in `tests/run-roms.sh`, Beamrider for
`vice_x64`) and the C64 row fails if the audio peak is zero, so a silent run
cannot pass as success.

## Test ROMs

`scripts/gen-test-rom.py` writes trivial homebrew images that park the CPU in an
infinite loop with a valid header. The system is chosen by output extension:

| Extension | System | Core |
| --------- | ------ | ---- |
| `.sms` | Sega Master System | `smsplus` |
| `.gb`, `.gbc` | Game Boy | `gambatte` |
| `.nes` | NES (iNES / NROM) | `quicknes`, `fceumm` |
| `.sfc`, `.smc` | SNES (LoROM) | `snes9x2002`, `snes9x2005` |
| `.gba` | Game Boy Advance | `gpsp`, `beetle_gba` |
| `.vec` | Vectrex | `vecx` |
| `.chf` | Fairchild Channel F | `freechaf` |
| `.vb`, `.vboy` | Virtual Boy | `beetle_vb` |
| `.o2` | Odyssey² | `o2em` (still needs `o2rom.bin`) |
| `.sna` | ZX Spectrum 48K snapshot | `fuse` |

Systems without a generator — Atari 2600 (`a26`), Atari 7800 (`a78`), Atari Lynx
(`lnx`), Intellivision (`int`), Neo Geo Pocket (`ngp`), WonderSwan (`ws`), PC
Engine (`pce`), SuperGrafx (`sgx`), Amstrad CPC (`cpc`), Pokémon Mini (`min`) —
are covered by the real-ROM matrix instead, so they are exercised as soon as the
ROM directory has a file.

`.mgw` is the one format a generator cannot fake convincingly. It *is* just a tar
v7 archive (`gwrom/`), and a synthetic one parses and loads, but the emulated
Sharp CPU then spins forever inside the nonsense program and `retro_run` never
returns — the core has to be killed, which is why `run-roms.sh` now wraps every
run in `timeout` and reports `HANG` instead of blocking. `gw` therefore needs
real `.mgw` ROMs; given them it runs (Donkey Kong Circus, 128x128). Generate one only when a core
has no content to test with at all; a generator that produces a *rejected* image
proves less than it appears to (`beetle_vb` needs a power-of-two ROM, and a
badly-sized generated file is what made it look broken).

## RAM budget

Because all cores are resident at once, the linker is the memory test. A build
that does not fit fails with:

```
region `ewram' overflowed by N bytes
```

Per-core totals (text+data+bss, ARMv5TE `-O2`) are listed in `common.mk` and the
README. A DS build has roughly 3.4 MiB of room, a DSi-mode build roughly 14 MiB.
Select a set with `make CORES="..."`.

## Single-core apps

```sh
./scripts/build-apps.sh [outdir]     # default: apps/
```

Builds one app per core (`apps/retrods-<core>.nds`). Each is the same libretro
host with exactly one core linked in, so the RAM budget applies per core instead
of to the sum of all of them. The script builds DS mode first and falls back to
DSi mode when a core does not fit 4 MiB. Current result: **28 apps built, none
failed — 23 DS mode and 5 DSi mode (`genesis_plus_gx`, `fceumm`, `vice_x64`,
`beetle_supergrafx`, `vecx`).**

Verified: `apps/retrods-quicknes.nds` and `apps/retrods-atari800.nds` were booted
in melonDS and render their console output, i.e. the single-core apps boot exactly
like the multi-core ROM.

To check an app boots, boot it in melonDS the same way as the multi-core ROM —
each app registers a single core, so it prints a one-line core list and holds:

```sh
"$RA" -L melonds_libretro.dylib apps/retrods-quicknes.nds \
    --appendconfig=append.cfg --max-frames=240 --max-frames-ss --max-frames-ss-path=shot.png
```

## Running real ROMs

```sh
tests/run-roms.sh /path/to/roms [/more/roms ...]
```

Takes any number of ROM directories (each is mounted read-only and searched), so
a collection split across folders is fine. It builds every core in the tree for
the host (no RAM limit there), then runs one real ROM per core and reports the
video geometry each core produced. If a directory contains a `bios/`
subdirectory it is passed as the system directory, so firmware-dependent cores
work the same way they will on hardware.

Firmware is looked up relative to the binary under test (`build-host/bios`),
which is the same `<app dir>/bios` rule the DS uses; the harness symlinks that to
the firmware tree it was given rather than overriding `RD_SYSTEM_DIR`, so the
relative lookup is what gets exercised. Getting this wrong — passing a host path
that does not exist inside the container — silently starves every
firmware-dependent core, which is how `o2em` once reported a missing BIOS while
the file sat right there. See `docs/BIOS.md`.

Firmware directories are excluded from the ROM search (`-not -path "*/bios/*"`).
Without that, `beetle_ngp` happily mounted `ngp-color-bios.ngp` as if it were a
cartridge — it rendered, so the row passed, while testing nothing.

It then does a second pass that the first cannot: for a list of core/extension
pairs it rebuilds the host with **one** core and opens a matching ROM *without*
`--core`, which is how Pico Launcher launches an app. That is the only way to
notice that a core does not claim an extension it should — `cap32` was missing
`.dsk`, so Amstrad CPC disk images were being opened by `fmsx`.

The matrix falls back to a generated ROM when the collection has none for a
core, and marks those rows `(synth)`. A run against a real collection
(3946 files) currently reports:

```
stella2014         OK    video 320x210  Pitfall!.a26
quicknes           OK    video 256x224  Zelda II - The Adventure of Link (U).nes
gambatte           OK    video 160x144  Super Mario Land 2 - 6 Golden Coins (UE) (V1.2) [!].gb
beetle_vb          OK    video 384x224  Space Invaders - Virtual Collection.vb
cap32              OK    video 768x272  Boulder Dash II - Rockford's Riot (1985)(Prism Leisure).dsk
gw                 OK    video 128x128  Donkey Kong Circus (Nintendo, Panorama Screen).mgw
vice_x64           OK    video 384x272  Beamrider (USA, Europe).crt
                   audio peak 16020
o2em               OK    video 340x250  synth.o2 (synth)
...
passed 27, failed 0, no ROM 1, needs a BIOS 0
mapping 19 ok, 0 wrong
```

## Launcher settings file

`scripts/gen-settings.py` writes the Pico Launcher associations from the same
registry the frontend compiles in (`make registry`), so an association cannot
point at a core that does not claim that extension, and it refuses to emit more
associations than the launcher can parse.

That limit is real, and worth re-measuring if pico-launcher changes. It parses
the file into a fixed `DynamicJsonDocument json(2048)` (`JSON_RESERVED_SIZE` in
`JsonAppSettingsSerializer.thumb.cpp`) and the input buffer is non-const, so
ArduinoJson *copies* every string into that pool. Measured with the launcher's
own copy of ArduinoJson (6.20.1), using realistic `/apps/retrods-*.nds` paths:

| Parser build | associations that fit | our 51-entry file |
| ------------ | --------------------- | ----------------- |
| 32-bit ARM — the ARM9's 4-byte pointers | **63** | `error=Ok memoryUsage=1648/2048` |
| 64-bit host — 8-byte pointers | 31 | `error=NoMemory` |

Measure it on 32-bit ARM, not on the host: ArduinoJson's slots are
pointer-sized, so a host build overflows at half the real count and reports a bug
that is not there.

```sh
docker run --rm --platform linux/arm/v7 -v "$PWD:/w" -w /w arm32v7/gcc \
    sh -c 'g++ -O1 -std=c++17 -o t t.cpp && ./t /w/settings.json'
```

Overflow is not a graceful failure: `deserializeJson` returns `NoMemory`,
`Deserialize` returns false, and `JsonAppSettingsService`'s constructor answers
that with `Save()`, overwriting the user's file with defaults.

## Host harness

```sh
./scripts/fetch-cores.sh
./tests/run-host.sh
```

It builds and runs inside the build container, because the host build needs the
same `objcopy`-based symbol renaming as the DS build (cores share helper code).
Artifacts land in `build-host/out/`:

* `frame_NNNN.ppm` — a sparse selection of rendered frames
* `audio.wav` — the audio the core produced
* `test.*.srm` — SRAM written on exit

| Variable | Default | Meaning |
| -------- | ------- | ------- |
| `RD_FRAMES` | `120` | frames to run before quitting |
| `RD_OUTDIR` | `build-host/out` | where artifacts are written |
| `RD_INPUT` | unset | script button combos by frame, e.g. `RD_INPUT="60:save,120:load,150:shot"` (also `fast`, `quit`, and ranges like `90-120:fast`) |

`RD_INPUT` exists because the harness has no input device but the hotkeys still
need testing: it applies the named combo for exactly the frames given, which is
what a real press looks like to the frontend's edge detection. `tests/run-host.sh`
uses it to check save states properly: it saves at frame 60, loads at frame 120,
and requires the frames 30 later to match (90 == 150, 120 == 180) — with a
control run first, so that a core whose output does not change over 60 frames is
reported as a skip rather than a pass.

Run one core directly, e.g.:

```sh
make -f Makefile.host CORES="testcore quicknes"
python3 scripts/gen-test-rom.py build-host/out/test.nes
RD_OUTDIR=build-host/out ./build-host/retrods-host build-host/out/test.nes
```

## Patching cores

If a core cannot work as-is, patch it instead of excluding it:

```sh
# edit third_party/<core>/..., then:
git -C third_party/<core> diff > patches/<core>/0001-something.patch
sh scripts/apply-patches.sh          # verifies it applies cleanly
```

Patches are plain unified diffs applied with `patch -p1`, so they work on trees
without git history. Keep them minimal, and prefer *disabling* an unsupported
feature over stubbing it: a patch should remove a code path that cannot work,
not fake it.

Where the feature is already `#ifdef`-guarded upstream, switch it off in
`cores/<name>.extra.mk` instead (see `vecx`, `gambatte`, `stella2014`).

## What you need to test the rest

1. **A DSpico and a DS/DSi** — the only way to exercise the real path: DLDI,
   the launcher's argv, real clocks, and DSi mode.
2. **Your own ROM dumps** for whichever cores you build.
3. **For a fully emulated end-to-end run** (argv included) you need Pico Loader
   itself: melonDS cannot write the homebrew argv structure at `0x02FFFE70`, so
   point a build of Pico Loader at the emulator
   (`make PICO_PLATFORM=MELONDS`, documented in its README), put
   `picoLoader7/9.bin`, `aplist.bin`, `savelist.bin`, Pico Launcher and
   `retrods.nds` plus a ROM on an SD image (`mkfatimg`), and boot the launcher
   in melonDS with that image mounted.

## Booting the DS build in an emulator

`retrods.nds` was verified by booting it in melonDS through RetroArch:

```sh
# once: get RetroArch and the core matching its architecture
brew install --cask retroarch                       # x86_64 build at time of writing
# the cask installs an app bundle, not a command on PATH
RA=/Applications/RetroArch.app/Contents/MacOS/RetroArch
curl -LO https://buildbot.libretro.com/nightly/apple/osx/x86_64/latest/melonds_libretro.dylib.zip
unzip melonds_libretro.dylib.zip

# RetroArch pauses whenever its window is not focused, which stops the DS from
# booting and leaves a blank capture. Disable that first:
printf 'pause_nonactive = "false"\n' > append.cfg

"$RA" -L melonds_libretro.dylib retrods.nds \
    --appendconfig=append.cfg --max-frames=240 \
    --max-frames-ss --max-frames-ss-path=shot.png
```

Launched with no ROM argument the app prints its core list and waits for START,
which exercises display init, the ARM7 sound driver, libfat/DLDI and the argv
path in one shot. melonDS provides a DLDI driver, so `fatInitDefault()` succeeds
there; on hardware it comes from Pico Loader, which is why the app must be
started *through Pico Launcher*.

## On hardware

Copy `apps/*.nds` to the SD card, copy the output of `scripts/gen-settings.py`
to `/_pico/settings.json`, then open a ROM from Pico Launcher. (A multi-core
`retrods.nds` can be booted directly and given `--core=<name>`.) The bottom screen shows a status console with
the core name and any error (e.g. `SD card init failed` means libfat could not
mount the SD card, i.e. DLDI was not patched).

Quit with **L + R + START + SELECT**, or press START on an error screen.
