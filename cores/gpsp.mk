# SPDX-License-Identifier: Zlib
#
# Generated from third_party/gpsp/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

gpsp_DIR := third_party/gpsp
gpsp_EXTS := gba

gpsp_SRCS := \
    third_party/gpsp/main.c \
    third_party/gpsp/gba_memory.c \
    third_party/gpsp/savestate.c \
    third_party/gpsp/input.c \
    third_party/gpsp/sound.c \
    third_party/gpsp/cheats.c \
    third_party/gpsp/memmap.c \
    third_party/gpsp/serial.c \
    third_party/gpsp/gbp.c \
    third_party/gpsp/rfu.c \
    third_party/gpsp/serial_proto.c \
    third_party/gpsp/libretro/libretro.c \
    third_party/gpsp/gba_cc_lut.c \
    third_party/gpsp/libretro/libretro-common/compat/compat_posix_string.c \
    third_party/gpsp/libretro/libretro-common/compat/compat_strl.c \
    third_party/gpsp/libretro/libretro-common/compat/fopen_utf8.c \
    third_party/gpsp/libretro/libretro-common/encodings/encoding_utf.c \
    third_party/gpsp/libretro/libretro-common/file/file_path.c \
    third_party/gpsp/libretro/libretro-common/file/file_path_io.c \
    third_party/gpsp/libretro/libretro-common/streams/file_stream.c \
    third_party/gpsp/libretro/libretro-common/string/stdstring.c \
    third_party/gpsp/libretro/libretro-common/time/rtime.c \
    third_party/gpsp/libretro/libretro-common/vfs/vfs_implementation.c

gpsp_ASM_SRCS := \
    third_party/gpsp/bios_data.S

gpsp_CXX_SRCS := \
    third_party/gpsp/video.cc \
    third_party/gpsp/cpu.cc

gpsp_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DHAVE_INTTYPES_H -DHAVE_STDINT_H -DHAVE_STRINGS_H -DINLINE=inline -DNDEBUG -D__LIBRETRO__

gpsp_INCLUDES := \
    -Ithird_party/gpsp/libretro \
    -Ithird_party/gpsp/libretro/libretro-common/include \
    -Ithird_party/gpsp

