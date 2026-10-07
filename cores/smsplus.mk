# SPDX-License-Identifier: Zlib
#
# Generated from third_party/smsplus/Makefile.libretro by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

smsplus_DIR := third_party/smsplus
smsplus_EXTS := sms gg sg col mv

smsplus_SRCS := \
    third_party/smsplus/source/sound/maxim_sn76489/sn76489.c \
    third_party/smsplus/source/loadrom.c \
    third_party/smsplus/source/memz80.c \
    third_party/smsplus/source/pio.c \
    third_party/smsplus/source/render.c \
    third_party/smsplus/source/sms.c \
    third_party/smsplus/source/system.c \
    third_party/smsplus/source/tms.c \
    third_party/smsplus/source/vdp.c \
    third_party/smsplus/source/cpu_cores/z80/z80.c \
    third_party/smsplus/source/sound/fmintf.c \
    third_party/smsplus/source/sound/sound.c \
    third_party/smsplus/source/sound/ym2413.c \
    third_party/smsplus/source/ntsc/sms_ntsc.c \
    third_party/smsplus/source/ports/libretro/libretro-common/streams/memory_stream.c \
    third_party/smsplus/source/ports/libretro/smsplus_libretro.c

smsplus_DEFINES := \
    -DHAVE_NTSC -DLSB_FIRST -DMAXIM_PSG -DNDEBUG -DNOZIP_SUPPORT -DUSE_Z80 -D__LIBRETRO__

smsplus_INCLUDES := \
    -Ithird_party/smsplus/source/ports/libretro \
    -Ithird_party/smsplus/source/ports/libretro/libretro-common/include \
    -Ithird_party/smsplus/source \
    -Ithird_party/smsplus/source/sound \
    -Ithird_party/smsplus/source/sound/maxim_sn76489 \
    -Ithird_party/smsplus/source/sound_output \
    -Ithird_party/smsplus/source/cpu_cores/z80 \
    -Ithird_party/smsplus/source/ntsc

