# SPDX-License-Identifier: Zlib
#
# Generated from third_party/beetle-wswan-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

beetle_wswan_DIR := third_party/beetle-wswan-libretro
beetle_wswan_EXTS := ws wsc

beetle_wswan_SRCS := \
    third_party/beetle-wswan-libretro/mednafen/wswan/sound.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/interrupt.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/comm.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/rtc.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/tcache.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/gfx.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/wswan-memory.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/v30mz.c \
    third_party/beetle-wswan-libretro/mednafen/wswan/eeprom.c \
    third_party/beetle-wswan-libretro/mednafen/sound/Blip_Buffer.c \
    third_party/beetle-wswan-libretro/mednafen/mempatcher.c \
    third_party/beetle-wswan-libretro/mednafen/state.c \
    third_party/beetle-wswan-libretro/mednafen/settings.c \
    third_party/beetle-wswan-libretro/libretro.c \
    third_party/beetle-wswan-libretro/libretro-common/compat/compat_strl.c \
    third_party/beetle-wswan-libretro/libretro-common/compat/compat_snprintf.c

beetle_wswan_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DINLINE=inline -DMEDNAFEN_VERSION_NUMERIC=931 -DMPC_FIXED_POINT -DNDEBUG -DSIZEOF_DOUBLE=8 -DSTDC_HEADERS -DWANT_16BPP -DWANT_STEREO_SOUND -D_LOW_ACCURACY_ -D__LIBRETRO__ -D__STDC_LIMIT_MACROS

beetle_wswan_INCLUDES := \
    -Ithird_party/beetle-wswan-libretro \
    -Ithird_party/beetle-wswan-libretro/mednafen \
    -Ithird_party/beetle-wswan-libretro/mednafen/include \
    -Ithird_party/beetle-wswan-libretro/mednafen/hw_sound \
    -Ithird_party/beetle-wswan-libretro/mednafen/hw_cpu \
    -Ithird_party/beetle-wswan-libretro/mednafen/hw_misc \
    -Ithird_party/beetle-wswan-libretro/libretro-common/include

