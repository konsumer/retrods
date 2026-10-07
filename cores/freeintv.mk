# SPDX-License-Identifier: Zlib
#
# Generated from third_party/freeintv/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

freeintv_DIR := third_party/freeintv
freeintv_EXTS := int

freeintv_SRCS := \
    third_party/freeintv/src/libretro.c \
    third_party/freeintv/src/intv.c \
    third_party/freeintv/src/memory.c \
    third_party/freeintv/src/cp1610.c \
    third_party/freeintv/src/cart.c \
    third_party/freeintv/src/controller.c \
    third_party/freeintv/src/osd.c \
    third_party/freeintv/src/ivoice.c \
    third_party/freeintv/src/psg.c \
    third_party/freeintv/src/stic.c \
    third_party/freeintv/src/stb_image_impl.c \
    third_party/freeintv/src/deps/libretro-common/file/file_path.c \
    third_party/freeintv/src/deps/libretro-common/file/file_path_io.c \
    third_party/freeintv/src/deps/libretro-common/compat/compat_posix_string.c \
    third_party/freeintv/src/deps/libretro-common/compat/compat_snprintf.c \
    third_party/freeintv/src/deps/libretro-common/compat/compat_strl.c \
    third_party/freeintv/src/deps/libretro-common/compat/compat_strcasestr.c \
    third_party/freeintv/src/deps/libretro-common/compat/fopen_utf8.c \
    third_party/freeintv/src/deps/libretro-common/encodings/encoding_utf.c \
    third_party/freeintv/src/deps/libretro-common/string/stdstring.c \
    third_party/freeintv/src/deps/libretro-common/streams/file_stream.c \
    third_party/freeintv/src/deps/libretro-common/time/rtime.c \
    third_party/freeintv/src/deps/libretro-common/vfs/vfs_implementation.c

freeintv_DEFINES := \
    -DNDEBUG -D__LIBRETRO__

freeintv_INCLUDES := \
    -Ithird_party/freeintv/src \
    -Ithird_party/freeintv/src/deps/libretro-common/include

