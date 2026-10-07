# SPDX-License-Identifier: Zlib
#
# Generated from third_party/libretro-handy/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

handy_DIR := third_party/libretro-handy
handy_EXTS := lnx

handy_SRCS := \
    third_party/libretro-handy/libretro-common/compat/compat_posix_string.c \
    third_party/libretro-handy/libretro-common/compat/compat_snprintf.c \
    third_party/libretro-handy/libretro-common/compat/compat_strcasestr.c \
    third_party/libretro-handy/libretro-common/compat/compat_strl.c \
    third_party/libretro-handy/libretro-common/compat/fopen_utf8.c \
    third_party/libretro-handy/libretro-common/encodings/encoding_utf.c \
    third_party/libretro-handy/libretro-common/file/file_path.c \
    third_party/libretro-handy/libretro-common/file/file_path_io.c \
    third_party/libretro-handy/libretro-common/streams/file_stream.c \
    third_party/libretro-handy/libretro-common/streams/file_stream_transforms.c \
    third_party/libretro-handy/libretro-common/string/stdstring.c \
    third_party/libretro-handy/libretro-common/time/rtime.c \
    third_party/libretro-handy/libretro-common/vfs/vfs_implementation.c

handy_CXX_SRCS := \
    third_party/libretro-handy/lynx/lynxdec.cpp \
    third_party/libretro-handy/lynx/cart.cpp \
    third_party/libretro-handy/lynx/memmap.cpp \
    third_party/libretro-handy/lynx/mikie.cpp \
    third_party/libretro-handy/lynx/ram.cpp \
    third_party/libretro-handy/lynx/rom.cpp \
    third_party/libretro-handy/lynx/susie.cpp \
    third_party/libretro-handy/lynx/system.cpp \
    third_party/libretro-handy/lynx/eeprom.cpp \
    third_party/libretro-handy/libretro/libretro.cpp \
    third_party/libretro-handy/blip/Blip_Buffer.cpp \
    third_party/libretro-handy/blip/Stereo_Buffer.cpp

handy_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DFRONTEND_SUPPORTS_XRGB8888 -DNDEBUG -DWANT_CRC32

handy_INCLUDES := \
    -Ithird_party/libretro-handy/lynx \
    -Ithird_party/libretro-handy/libretro \
    -Ithird_party/libretro-handy \
    -Ithird_party/libretro-handy/libretro-common/include

