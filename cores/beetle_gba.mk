# SPDX-License-Identifier: Zlib
#
# Generated from third_party/beetle-gba-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

beetle_gba_DIR := third_party/beetle-gba-libretro
beetle_gba_EXTS := gba

beetle_gba_SRCS := \
    third_party/beetle-gba-libretro/libretro-common/streams/file_stream.c \
    third_party/beetle-gba-libretro/libretro-common/compat/fopen_utf8.c \
    third_party/beetle-gba-libretro/libretro-common/compat/compat_strl.c \
    third_party/beetle-gba-libretro/libretro-common/encodings/encoding_utf.c \
    third_party/beetle-gba-libretro/libretro-common/vfs/vfs_implementation.c \
    third_party/beetle-gba-libretro/libretro-common/string/stdstring.c \
    third_party/beetle-gba-libretro/libretro-common/file/file_path.c \
    third_party/beetle-gba-libretro/libretro-common/time/rtime.c

beetle_gba_CXX_SRCS := \
    third_party/beetle-gba-libretro/mednafen/gba/GBA.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/arm.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/bios.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/eeprom.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/flash.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/GBAinline.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Gfx.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Globals.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Mode0.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Mode1.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Mode2.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Mode3.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Mode4.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Mode5.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/RTC.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/Sound.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/sram.cpp \
    third_party/beetle-gba-libretro/mednafen/gba/thumb.cpp \
    third_party/beetle-gba-libretro/mednafen/hw_sound/gb_apu/Gb_Apu.cpp \
    third_party/beetle-gba-libretro/mednafen/hw_sound/gb_apu/Gb_Apu_State.cpp \
    third_party/beetle-gba-libretro/mednafen/hw_sound/gb_apu/Gb_Oscs.cpp \
    third_party/beetle-gba-libretro/mednafen/sound/Blip_Buffer.cpp \
    third_party/beetle-gba-libretro/mednafen/settings.cpp \
    third_party/beetle-gba-libretro/mednafen/state.cpp \
    third_party/beetle-gba-libretro/mednafen/mempatcher.cpp \
    third_party/beetle-gba-libretro/mednafen/md5.cpp \
    third_party/beetle-gba-libretro/mednafen/file.cpp \
    third_party/beetle-gba-libretro/mednafen/sound/Stereo_Buffer.cpp \
    third_party/beetle-gba-libretro/mednafen/video/surface.cpp \
    third_party/beetle-gba-libretro/mednafen/endian.cpp \
    third_party/beetle-gba-libretro/libretro.cpp

beetle_gba_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DMEDNAFEN_VERSION_NUMERIC=931 -DMPC_FIXED_POINT -DSIZEOF_DOUBLE=8 -DSTDC_HEADERS -DTILED_RENDERING -DWANT_32BPP -DWANT_STEREO_SOUND -D_LOW_ACCURACY_ -D__LIBRETRO__ -D__STDC_LIMIT_MACROS

beetle_gba_INCLUDES := \
    -Ithird_party/beetle-gba-libretro \
    -Ithird_party/beetle-gba-libretro/mednafen \
    -Ithird_party/beetle-gba-libretro/mednafen/include \
    -Ithird_party/beetle-gba-libretro/mednafen/hw_sound \
    -Ithird_party/beetle-gba-libretro/libretro-common/include

