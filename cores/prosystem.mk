# SPDX-License-Identifier: Zlib
#
# Generated from third_party/prosystem-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

prosystem_DIR := third_party/prosystem-libretro
prosystem_EXTS := a78

prosystem_SRCS := \
    third_party/prosystem-libretro/core/libretro.c \
    third_party/prosystem-libretro/core/Bios.c \
    third_party/prosystem-libretro/core/BupChip.c \
    third_party/prosystem-libretro/core/Cartridge.c \
    third_party/prosystem-libretro/core/Database.c \
    third_party/prosystem-libretro/core/Hash.c \
    third_party/prosystem-libretro/core/Maria.c \
    third_party/prosystem-libretro/core/Memory.c \
    third_party/prosystem-libretro/core/Palette.c \
    third_party/prosystem-libretro/core/Pokey.c \
    third_party/prosystem-libretro/core/ProSystem.c \
    third_party/prosystem-libretro/core/Region.c \
    third_party/prosystem-libretro/core/Riot.c \
    third_party/prosystem-libretro/core/Sally.c \
    third_party/prosystem-libretro/core/Tia.c \
    third_party/prosystem-libretro/bupboop/coretone/channel.c \
    third_party/prosystem-libretro/bupboop/coretone/coretone.c \
    third_party/prosystem-libretro/bupboop/coretone/music.c \
    third_party/prosystem-libretro/bupboop/coretone/sample.c \
    third_party/prosystem-libretro/libretro-common/compat/compat_posix_string.c \
    third_party/prosystem-libretro/libretro-common/compat/compat_strcasestr.c \
    third_party/prosystem-libretro/libretro-common/compat/compat_snprintf.c \
    third_party/prosystem-libretro/libretro-common/compat/compat_strl.c \
    third_party/prosystem-libretro/libretro-common/compat/fopen_utf8.c \
    third_party/prosystem-libretro/libretro-common/encodings/encoding_utf.c \
    third_party/prosystem-libretro/libretro-common/file/file_path.c \
    third_party/prosystem-libretro/libretro-common/file/file_path_io.c \
    third_party/prosystem-libretro/libretro-common/streams/file_stream.c \
    third_party/prosystem-libretro/libretro-common/streams/file_stream_transforms.c \
    third_party/prosystem-libretro/libretro-common/string/stdstring.c \
    third_party/prosystem-libretro/libretro-common/time/rtime.c \
    third_party/prosystem-libretro/libretro-common/vfs/vfs_implementation.c

prosystem_DEFINES := \
    -DNDEBUG -D__LIBRETRO__

prosystem_INCLUDES := \
    -Ithird_party/prosystem-libretro/core \
    -Ithird_party/prosystem-libretro/libretro-common/include

