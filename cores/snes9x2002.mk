# SPDX-License-Identifier: Zlib
#
# Generated from third_party/snes9x2002/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

snes9x2002_DIR := third_party/snes9x2002
snes9x2002_EXTS := sfc smc

snes9x2002_SRCS := \
    third_party/snes9x2002/src/apu.c \
    third_party/snes9x2002/src/apuaux.c \
    third_party/snes9x2002/src/c4.c \
    third_party/snes9x2002/src/c4emu.c \
    third_party/snes9x2002/src/cheats.c \
    third_party/snes9x2002/src/cheats2.c \
    third_party/snes9x2002/src/clip.c \
    third_party/snes9x2002/src/data.c \
    third_party/snes9x2002/src/dsp1.c \
    third_party/snes9x2002/src/fxemu.c \
    third_party/snes9x2002/src/fxinst.c \
    third_party/snes9x2002/src/globals.c \
    third_party/snes9x2002/src/dma.c \
    third_party/snes9x2002/src/memmap.c \
    third_party/snes9x2002/src/cpu.c \
    third_party/snes9x2002/src/cpuexec.c \
    third_party/snes9x2002/src/cpuops.c \
    third_party/snes9x2002/src/sa1.c \
    third_party/snes9x2002/src/sa1cpu.c \
    third_party/snes9x2002/src/sdd1.c \
    third_party/snes9x2002/src/sdd1emu.c \
    third_party/snes9x2002/src/snapshot.c \
    third_party/snes9x2002/src/soundux.c \
    third_party/snes9x2002/src/spc700.c \
    third_party/snes9x2002/src/srtc.c \
    third_party/snes9x2002/libretro/libretro.c \
    third_party/snes9x2002/libretro/libretro-common/streams/memory_stream.c \
    third_party/snes9x2002/src/ppu_.c \
    third_party/snes9x2002/src/gfx.c \
    third_party/snes9x2002/src/tile.c

snes9x2002_DEFINES := \
    -DHAVE_INTTYPES_H -DHAVE_STDINT_H -DHAVE_STRINGS_H -DLAGFIX -DNDEBUG=1 -DUSE_SA1 -D__LIBRETRO__ -D__OLD_RASTER_FX__

snes9x2002_INCLUDES := \
    -Ithird_party/snes9x2002 \
    -Ithird_party/snes9x2002/libretro \
    -Ithird_party/snes9x2002/libretro/libretro-common/include \
    -Ithird_party/snes9x2002/src

