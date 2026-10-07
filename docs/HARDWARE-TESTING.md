# Testing on hardware

Everything in this repo is verified on the **host** harness, which exercises the
frontend, the cores, the run loop, save states and the command-line path. What it
cannot exercise is the DS itself: DLDI, the launcher's argv hand-off, the real
clock, the framebuffer blit, the ARM7 sound path, the keymap, DSi mode.

This is the procedure for closing that gap. Work down section A first — if the
plumbing is wrong, every core will look broken.

## Before you start

Card layout, which the apps depend on:

```
apps/retrods-<core>.nds     31 apps
apps/bios/                  firmware, read relative to the .nds
apps/saves/                 where saves land
roms/                       one directory per system
_pico/settings.json         the associations that launch them
```

Boot the console, open Pico Launcher, and you should see the 31 apps listed.

## A. Plumbing (do these first)

1. **An app launches with its ROM.** Open `roms/nes/Zelda II - The Adventure of
   Link (U).nes` from the launcher's browser. It should open *in* retrods-quicknes
   without a menu — that proves the association resolved and argv arrived.
2. **The bottom screen.** Keep an eye on it. Every app prints its core name there
   (`core: quicknes (QuickNES ...)`) and any error. When something fails, that
   line is the diagnosis — please quote it in a report.
3. **Exit works.** `L+R+START+SELECT` should return you to Pico Launcher.
4. **Firmware is found.** Its absence is explicit, e.g. `o2em` prints
   `Error loading BIOS ROM (<system dir>/o2rom.bin)`. With `apps/bios/o2rom.bin`
   present it should load `roms/odyssey2/test.o2` instead.
5. **A large ROM.** Try a big GBA cartridge. The frontend reads the whole file
   into RAM, so on a DS (4 MiB) anything much over 3 MiB should fail to load, and
   on a DSi (~16 MiB) over ~14 MiB. If it fails, that is expected — say so rather
   than treating it as a core bug.

## B. One ROM per core

Launch each of these from the launcher and check that video appears, looks like
the right machine, and moves. The video size is what the host produced; the DS
scales it to 256x192, so what you are checking is that it is not stretched or
cropped wrongly and that the colours look right.

| App | System | ROM on the card | Video (host) |
|---|---|---|---|
| `retrods-cap32.nds` | Amstrad CPC | `roms/cpc/Boulder Dash II - Rockford's Riot (1985)(Prism Leisure).dsk` | 768x272 |
| `retrods-prosystem.nds` | Atari 7800 | `roms/atari7800/Asteroids (USA).a78` | 320x223 |
| `retrods-atari800.nds` | Atari 8-bit | `roms/atari800/R/Reforger '88 _ side A.atr` | 336x240 |
| `retrods-handy.nds` | Atari Lynx | `roms/lynx/Awesome Golf (USA, Europe).lnx` | 160x102 |
| `retrods-freechaf.nds` | Channel F | `roms/channelf/test.chf` | 306x192 |
| `retrods-vice_x64.nds` | Commodore 64 | `roms/c64/Adventure 1 - The Mutant Spiders (USA, Europe).crt` | 384x272 |
| `retrods-gambatte.nds` | GB / GBC | `roms/gb/Super Mario Land 2 - 6 Golden Coins (UE) (V1.2) [!].gb` | 160x144 |
| `retrods-beetle_gba.nds` | GBA | `roms/gba/Kingdom Hearts - Chain of Memories.gba` | 240x160 |
| `retrods-gpsp.nds` | GBA (alt) | `roms/gba/Kingdom Hearts - Chain of Memories.gba` | 240x160 |
| `retrods-gw.nds` | Game & Watch | `roms/gameandwatch/Donkey Kong Circus (Nintendo, Panorama Screen).mgw` | 128x128 |
| `retrods-freeintv.nds` | Intellivision | `roms/intv/Spirit V1.0 (2003) (Arnauld Chevallier).int` | 352x224 |
| `retrods-fmsx.nds` | MSX | `roms/msx/Metal Gear 2 - Solid Snake (Japan).rom` | 272x228 |
| `retrods-genesis_plus_gx.nds` | Mega Drive | `roms/genesis/Streets of Rage 2 (U) [!].gen` | 256x192 |
| `retrods-quicknes.nds` | NES | `roms/nes/Zelda II - The Adventure of Link (U).nes` | 256x224 |
| `retrods-fceumm.nds` | NES (alt) | `roms/nes/Zelda II - The Adventure of Link (U).nes` | 256x224 |
| `retrods-beetle_ngp.nds` | Neo Geo Pocket | `roms/ngpocket/Samurai Shodown! - Pocket Fighting Series (Japan, Europe) (En,Ja).ngp` | 160x152 |
| `retrods-o2em.nds` | Odyssey2 | `roms/odyssey2/test.o2` | 340x250 |
| `retrods-beetle_pce_fast.nds` | PC Engine | `roms/pce/Blazing Lazers (USA).pce` | 256x243 |
| `retrods-pokemini.nds` | Pokemon Mini | `roms/pokemini/Lunch Time (USA) (GameCube).min` | 384x256 |
| `retrods-smsplus.nds` | SMS / GG / Coleco | `roms/sms/Aleste.sms` | 256x192 |
| `retrods-snes9x2005.nds` | SNES | `roms/snes/Super Mario World.smc` | 256x224 |
| `retrods-snes9x2002.nds` | SNES (alt) | `roms/snes/Super Mario World.smc` | 256x224 |
| `retrods-beetle_supergrafx.nds` | SuperGrafx | `roms/pce/Blazing Lazers (USA).pce` | 352x240 |
| `retrods-potator.nds` | Supervision | `roms/supervision/Balloon Fight (USA, Europe).sv` | 160x160 |
| `retrods-ti99.nds` | TI-99/4A | `-- no ROM --` | n/a |
| `retrods-vecx.nds` | Vectrex | `roms/vectrex/test.vec` | 330x410 |
| `retrods-beetle_vb.nds` | Virtual Boy | `roms/virtualboy/Space Invaders - Virtual Collection.vb` | 384x224 |
| `retrods-beetle_wswan.nds` | WonderSwan | `roms/wonderswan/Kaze no Klonoa - Moonlight Museum (Japan).ws` | 224x144 |
| `retrods-fuse.nds` | ZX Spectrum | `roms/zxspectrum/test.sna` | 320x240 |
| `retrods-stella2014.nds` | Atari 2600 | `roms/atari2600/Pitfall!.a26` | 320x210 |


## C. Everything that is not "does it draw"

These are shared code paths, so a handful of cores is enough — use `quicknes`,
`gambatte` and `vice_x64`.

| Feature | How | What should happen |
| --- | --- | --- |
| Save state | `L+R+START` | bottom screen: `state: saved N bytes to <rom>.state` |
| Load state | `L+R+SELECT` | same, says `loaded`. Save, play on, load: the game should jump back |
| Save across power | save, turn the console off, back on, load | resumes where you saved |
| Screenshot | `L+R+X` | `<rom>_<frame>.bmp` next to the ROM; check it opens on the Mac |
| Fast-forward | hold `L+R+A` | the game runs several times faster while held |
| Quit | `L+R+START+SELECT` | back to Pico Launcher, no hang |

## D. Expected to fail, or not to exist

* **`retrods-ti99.nds`** — the app is on the card, but no TI-99 cartridge exists
  here, so there is nothing to load. Its own `bin`/`g` extensions are unverified.
* **`.neo` files** in `roms/neogeo` (removed from this card) have no core
  anywhere; that is why the extension is unassociated.
* **DSi-mode apps** (6 of them: `fuse`, `genesis_plus_gx`, `fceumm`, `vice_x64`,
  `beetle_supergrafx`, `vecx`) will not run on an original DS or DS Lite — they
  need DSi mode for the extra RAM. On a DS, skip them or expect a load failure.
* **`gw`** maps holds to Run/Time rather than a d-pad, so its controls are odd by
  design.
* **Input has never been tested on hardware.** If a button does nothing or does
  the wrong thing, that is the most likely bug, and it will affect every core.

## E. What to report

For each problem, the useful shape is:

```
app:      retrods-<core>.nds
ROM:      roms/<path>
what I did:  ...
what happened:  ...
bottom screen said:  ...
```

A black screen with a core name on the bottom screen is a different bug from a
black screen with an error message, and the two need different fixes.
