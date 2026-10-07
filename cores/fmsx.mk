# SPDX-License-Identifier: Zlib
#
# Generated from third_party/fmsx-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

fmsx_DIR := third_party/fmsx-libretro
fmsx_EXTS := rom mx1 mx2 dsk cas

fmsx_SRCS := \
    third_party/fmsx-libretro/libretro.c \
    third_party/fmsx-libretro/EMULib/Sound.c \
    third_party/fmsx-libretro/fMSX/MSX.c \
    third_party/fmsx-libretro/fMSX/V9938.c \
    third_party/fmsx-libretro/EMULib/SHA1.c \
    third_party/fmsx-libretro/EMULib/Floppy.c \
    third_party/fmsx-libretro/EMULib/FDIDisk.c \
    third_party/fmsx-libretro/EMULib/MCF.c \
    third_party/fmsx-libretro/Z80/Z80.c \
    third_party/fmsx-libretro/EMULib/I8255.c \
    third_party/fmsx-libretro/EMULib/YM2413.c \
    third_party/fmsx-libretro/EMULib/AY8910.c \
    third_party/fmsx-libretro/EMULib/SCC.c \
    third_party/fmsx-libretro/EMULib/WD1793.c \
    third_party/fmsx-libretro/NukeYKT/opll.c \
    third_party/fmsx-libretro/NukeYKT/WrapNukeYKT.c \
    third_party/fmsx-libretro/libretro-common/file/retro_dirent.c \
    third_party/fmsx-libretro/libretro-common/file/file_path.c \
    third_party/fmsx-libretro/libretro-common/file/file_path_io.c \
    third_party/fmsx-libretro/libretro-common/compat/compat_posix_string.c \
    third_party/fmsx-libretro/libretro-common/compat/compat_strl.c \
    third_party/fmsx-libretro/libretro-common/compat/compat_snprintf.c \
    third_party/fmsx-libretro/libretro-common/compat/fopen_utf8.c \
    third_party/fmsx-libretro/libretro-common/compat/compat_strcasestr.c \
    third_party/fmsx-libretro/libretro-common/encodings/encoding_utf.c \
    third_party/fmsx-libretro/libretro-common/streams/file_stream.c \
    third_party/fmsx-libretro/libretro-common/streams/file_stream_transforms.c \
    third_party/fmsx-libretro/libretro-common/time/rtime.c \
    third_party/fmsx-libretro/libretro-common/string/stdstring.c \
    third_party/fmsx-libretro/libretro-common/vfs/vfs_implementation.c \
    third_party/fmsx-libretro/fMSX/Patch.c

fmsx_DEFINES := \
    -DNDEBUG -DPATCH_Z80 -DSKIP_STDIO_REDEFINES -D__LIBRETRO__

fmsx_INCLUDES := \
    -Ithird_party/fmsx-libretro \
    -Ithird_party/fmsx-libretro/libretro-common/include \
    -Ithird_party/fmsx-libretro/EMULib \
    -Ithird_party/fmsx-libretro/Z80 \
    -Ithird_party/fmsx-libretro/fMSX

