# SPDX-License-Identifier: Zlib
#
# Generated from third_party/beetle-ngp-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

beetle_ngp_DIR := third_party/beetle-ngp-libretro
beetle_ngp_EXTS := ngp ngc

beetle_ngp_SRCS := \
    third_party/beetle-ngp-libretro/mednafen/ngp/biosHLE.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/bios.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/flash.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/dma.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/gfx.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/interrupt.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/mem.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/rom.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/system.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/TLCS-900h/TLCS900h_interpret.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/TLCS-900h/TLCS900h_interpret_dst.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/TLCS-900h/TLCS900h_interpret_reg.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/TLCS-900h/TLCS900h_interpret_single.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/TLCS-900h/TLCS900h_interpret_src.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/TLCS-900h/TLCS900h_registers.c \
    third_party/beetle-ngp-libretro/mednafen/hw_cpu/z80-fuse/z80_ops.c \
    third_party/beetle-ngp-libretro/mednafen/hw_cpu/z80-fuse/z80.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/rtc.c \
    third_party/beetle-ngp-libretro/mednafen/ngp/Z80_interface.c \
    third_party/beetle-ngp-libretro/mednafen/state.c \
    third_party/beetle-ngp-libretro/libretro.c \
    third_party/beetle-ngp-libretro/libretro-common/streams/file_stream.c \
    third_party/beetle-ngp-libretro/libretro-common/compat/fopen_utf8.c \
    third_party/beetle-ngp-libretro/libretro-common/compat/compat_strl.c \
    third_party/beetle-ngp-libretro/libretro-common/compat/compat_snprintf.c \
    third_party/beetle-ngp-libretro/libretro-common/encodings/encoding_utf.c \
    third_party/beetle-ngp-libretro/libretro-common/vfs/vfs_implementation.c \
    third_party/beetle-ngp-libretro/libretro-common/file/file_path.c \
    third_party/beetle-ngp-libretro/libretro-common/time/rtime.c \
    third_party/beetle-ngp-libretro/libretro-common/string/stdstring.c \
    third_party/beetle-ngp-libretro/libretro-common/compat/compat_posix_string.c \
    third_party/beetle-ngp-libretro/mednafen/settings.c

beetle_ngp_CXX_SRCS := \
    third_party/beetle-ngp-libretro/mednafen/ngp/sound.cpp \
    third_party/beetle-ngp-libretro/mednafen/ngp/T6W28_Apu.cpp \
    third_party/beetle-ngp-libretro/mednafen/sound/Blip_Buffer.cpp \
    third_party/beetle-ngp-libretro/mednafen/mempatcher.cpp \
    third_party/beetle-ngp-libretro/mednafen/sound/Stereo_Buffer.cpp

beetle_ngp_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DINLINE=inline -DLOAD_FROM_MEMORY -DMEDNAFEN_VERSION_NUMERIC=931 -DNDEBUG -DSTDC_HEADERS -DWANT_16BPP -D__LIBRETRO__ -D__STDC_LIMIT_MACROS

beetle_ngp_INCLUDES := \
    -Ithird_party/beetle-ngp-libretro \
    -Ithird_party/beetle-ngp-libretro/mednafen \
    -Ithird_party/beetle-ngp-libretro/mednafen/include \
    -Ithird_party/beetle-ngp-libretro/mednafen/intl \
    -Ithird_party/beetle-ngp-libretro/mednafen/hw_sound \
    -Ithird_party/beetle-ngp-libretro/mednafen/hw_cpu \
    -Ithird_party/beetle-ngp-libretro/mednafen/hw_misc \
    -Ithird_party/beetle-ngp-libretro/libretro-common/include

