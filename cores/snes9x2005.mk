# SPDX-License-Identifier: Zlib
#
# Generated from third_party/snes9x2005/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

snes9x2005_DIR := third_party/snes9x2005
snes9x2005_EXTS := sfc smc

snes9x2005_SRCS := \
    third_party/snes9x2005/source/c4.c \
    third_party/snes9x2005/source/c4emu.c \
    third_party/snes9x2005/source/cheats2.c \
    third_party/snes9x2005/source/cheats.c \
    third_party/snes9x2005/source/clip.c \
    third_party/snes9x2005/source/cpu.c \
    third_party/snes9x2005/source/cpuexec.c \
    third_party/snes9x2005/source/cpuops.c \
    third_party/snes9x2005/source/data.c \
    third_party/snes9x2005/source/dma.c \
    third_party/snes9x2005/source/dsp1.c \
    third_party/snes9x2005/source/fxemu.c \
    third_party/snes9x2005/source/fxinst.c \
    third_party/snes9x2005/source/gfx.c \
    third_party/snes9x2005/source/getset.c \
    third_party/snes9x2005/source/globals.c \
    third_party/snes9x2005/source/memmap.c \
    third_party/snes9x2005/source/obc1.c \
    third_party/snes9x2005/source/ppu.c \
    third_party/snes9x2005/source/sa1.c \
    third_party/snes9x2005/source/sa1cpu.c \
    third_party/snes9x2005/source/sdd1.c \
    third_party/snes9x2005/source/sdd1emu.c \
    third_party/snes9x2005/source/seta010.c \
    third_party/snes9x2005/source/seta011.c \
    third_party/snes9x2005/source/seta018.c \
    third_party/snes9x2005/source/seta.c \
    third_party/snes9x2005/source/spc7110.c \
    third_party/snes9x2005/source/spc7110dec.c \
    third_party/snes9x2005/source/srtc.c \
    third_party/snes9x2005/source/tile.c \
    third_party/snes9x2005/libretro.c \
    third_party/snes9x2005/source/apu.c \
    third_party/snes9x2005/source/soundux.c \
    third_party/snes9x2005/source/spc700.c

snes9x2005_DEFINES := \
    -DLAGFIX -DLOAD_FROM_MEMORY -DNDEBUG

snes9x2005_INCLUDES := \
    -Ithird_party/snes9x2005/source \
    -Ithird_party/snes9x2005 \
    -Ithird_party/snes9x2005/libretro-common/include

