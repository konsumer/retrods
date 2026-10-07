# Firmware / BIOS files

Cores look for firmware in **`<app dir>/bios`** — the directory the `.nds` files
themselves live in — and write saves to `<app dir>/saves`.

Both are derived from `argv[0]`, and `argv[0]` really is the app's own path:
pico-launcher puts the associated app in `loadParams.romPath`
(`CustomFileType::TrySetLaunchParameters`) and passes the selected ROM in
`arguments`, pico-loader's `NdsLoader::InsertArgv` writes them as the first two
command-line entries, and libnds's `build_argv()` turns that into `argc`/`argv`.
So `retrods-o2em.nds` in `/apps` resolves to `/apps/bios`, and one directory on
the card is the whole deployment:

```
SD card
└── apps/
    ├── retrods-quicknes.nds        # one app per core
    ├── retrods-gambatte.nds
    ├── ...
    ├── bios/                       # where cores look, and only where
    │   ├── o2rom.bin
    │   ├── voice/E480.WAV ...
    │   └── README.txt
    └── saves/
```

`scripts/build-apps.sh` creates the output directory but never clears it, so
`apps/bios` and `apps/saves` survive a rebuild and the whole `apps` directory can
be copied to the card as-is: 28 apps, 42 firmware files and 270 voice samples,
2.8 MiB in total.

The frontend asks the platform for `rd_plat_system_dir()` / `rd_plat_save_dir()`
once and hands them to cores through `RETRO_ENVIRONMENT_GET_SYSTEM_DIRECTORY` /
`GET_SAVE_DIRECTORY`; on the DS those are `fat:<dir of argv[0]>/bios` and
`.../saves`, and a bare `/apps/...` path gets the `fat:` prefix libfat expects.

## What the cores actually ask for

Each filename below is a literal in the vendored core that reads it, so this is
what *this* build asks for rather than what upstream documentation claims:

| File | Core | Used for | Required |
| ---- | ---- | -------- | -------- |
| `o2rom.bin` | `o2em` | Odyssey² BIOS, 1 KiB | **yes** |
| `48.rom`, `128.rom` | `fuse` | Spectrum ROM — **built into the core**; external copies are optional overrides | no |
| `voice/*.WAV` | `o2em` | The Voice speech module | no |
| `gba_bios.bin` | `beetle_gba` | GBA BIOS | no — `gpsp` has a built-in HLE BIOS |
| `gbc_bios.bin`, `gb_bios.bin` | `gambatte` | boot animation | no |
| `disksys.rom` | `fceumm` | Famicom Disk System | no |
| `atarixl.rom`, `atariosb.rom`, `ataribas.rom` | `atari800` | Atari 8-bit OS ROMs | no |
| `5200.rom` | `atari800` | Atari 5200 BIOS | no |
| `exec.bin`, `grom.bin` | `freeintv` | Intellivision | no |
| `syscard3.pce` | `beetle_pce_fast`, `beetle_supergrafx` | CD BIOS — CD games are unsupported in this build | no |
| `ggenie.bin`, `areplay.bin` | `genesis_plus_gx` | Game Genie / Action Replay | no |
| `JiffyDOS_*.bin` | `vice_x64` | JiffyDOS ROMs | no |

Only one file is genuinely required. Everything else is optional: the whole
matrix passes with no firmware present except `o2rom.bin`, which `o2em` refuses
content without — and it says so, naming the path it looked in:

```
retrods: [O2EM]: Error loading BIOS ROM (<app dir>/bios/o2rom.bin).
retrods: core rejected content: /path/to/game.o2
```

Cores that need nothing at all: `potator` (Supervision), `fuse` (ZX Spectrum —
ROM built in), `smsplus` (including ColecoVision), `quicknes`,
`gpsp`, `beetle_gba`, `snes9x2002`, `snes9x2005`, `beetle_ngp` (built-in BIOS,
verified against a real cartridge), `beetle_wswan`, `beetle_vb`, `stella2014`,
`prosystem`, `handy`, `freechaf`, `fmsx`, `pokemini`, `vecx`, `cap32`, `gw` and
`vice_x64` (verified with an empty system directory).

Files belonging to cores this build does not include are harmless here — the
directory is one place to keep firmware, not a per-core checklist.

## Where to get them

* `o2rom.bin` and the 270 `voice/*.WAV` samples are in the
  [retrobios](https://github.com/Abdess/retrobios) collection under
  `bios/Magnavox/Odyssey2/`.
* Everything else is a dump of hardware you own, or a copy you already have.
  None of it is included here: the files in `apps/bios` are placed there by
  whoever builds the card, and they keep their own copyright.

## How this is tested

`tests/run-roms.sh` links `<app dir>/bios` to the firmware tree it was given, so
the tests exercise the same relative-path lookup the DS uses instead of an
override. A core that cannot find firmware is reported as its own category —
`needs a system BIOS` — so a missing file is never counted as a core failure,
while a core that silently does nothing still fails.
