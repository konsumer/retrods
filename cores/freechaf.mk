# SPDX-License-Identifier: Zlib
#
# Generated from third_party/freechaf/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

freechaf_DIR := third_party/freechaf
freechaf_EXTS := chf

freechaf_SRCS := \
    third_party/freechaf/src/libretro.c \
    third_party/freechaf/src/channelf.c \
    third_party/freechaf/src/memory.c \
    third_party/freechaf/src/f8.c \
    third_party/freechaf/src/f2102.c \
    third_party/freechaf/src/controller.c \
    third_party/freechaf/src/audio.c \
    third_party/freechaf/src/video.c \
    third_party/freechaf/src/ports.c \
    third_party/freechaf/src/osd.c \
    third_party/freechaf/src/channelf_hle.c \
    third_party/freechaf/src/deps/libretro-common/compat/compat_posix_string.c \
    third_party/freechaf/src/deps/libretro-common/compat/compat_snprintf.c \
    third_party/freechaf/src/deps/libretro-common/compat/compat_strcasestr.c \
    third_party/freechaf/src/deps/libretro-common/compat/compat_strl.c \
    third_party/freechaf/src/deps/libretro-common/compat/fopen_utf8.c \
    third_party/freechaf/src/deps/libretro-common/encodings/encoding_utf.c \
    third_party/freechaf/src/deps/libretro-common/file/file_path.c \
    third_party/freechaf/src/deps/libretro-common/file/file_path_io.c \
    third_party/freechaf/src/deps/libretro-common/streams/file_stream.c \
    third_party/freechaf/src/deps/libretro-common/streams/file_stream_transforms.c \
    third_party/freechaf/src/deps/libretro-common/streams/memory_stream.c \
    third_party/freechaf/src/deps/libretro-common/string/stdstring.c \
    third_party/freechaf/src/deps/libretro-common/time/rtime.c \
    third_party/freechaf/src/deps/libretro-common/vfs/vfs_implementation.c

freechaf_DEFINES := \
    -DNDEBUG -D__LIBRETRO__

freechaf_INCLUDES := \
    -Ithird_party/freechaf/src/deps/libretro-common/include

