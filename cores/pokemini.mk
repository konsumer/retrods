# SPDX-License-Identifier: Zlib
#
# Generated from third_party/PokeMini/Makefile.libretro by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

pokemini_DIR := third_party/PokeMini
pokemini_EXTS := min

pokemini_SRCS := \
    third_party/PokeMini/freebios/freebios.c \
    third_party/PokeMini/source/CommandLine.c \
    third_party/PokeMini/source/Hardware.c \
    third_party/PokeMini/source/Joystick.c \
    third_party/PokeMini/source/MinxAudio.c \
    third_party/PokeMini/source/MinxColorPRC.c \
    third_party/PokeMini/source/MinxCPU_CE.c \
    third_party/PokeMini/source/MinxCPU_CF.c \
    third_party/PokeMini/source/MinxCPU_SP.c \
    third_party/PokeMini/source/MinxCPU_XX.c \
    third_party/PokeMini/source/MinxCPU.c \
    third_party/PokeMini/source/MinxIO.c \
    third_party/PokeMini/source/MinxIRQ.c \
    third_party/PokeMini/source/MinxLCD.c \
    third_party/PokeMini/source/MinxPRC.c \
    third_party/PokeMini/source/MinxTimers.c \
    third_party/PokeMini/source/Multicart.c \
    third_party/PokeMini/source/PMCommon.c \
    third_party/PokeMini/source/PokeMini.c \
    third_party/PokeMini/source/Video_x1.c \
    third_party/PokeMini/source/Video_x2.c \
    third_party/PokeMini/source/Video_x3.c \
    third_party/PokeMini/source/Video_x4.c \
    third_party/PokeMini/source/Video_x5.c \
    third_party/PokeMini/source/Video_x6.c \
    third_party/PokeMini/source/Video_x7.c \
    third_party/PokeMini/source/Video.c \
    third_party/PokeMini/resource/PokeMini_ColorPal.c \
    third_party/PokeMini/libretro/libretro.c \
    third_party/PokeMini/libretro/libretro-common/compat/compat_posix_string.c \
    third_party/PokeMini/libretro/libretro-common/compat/compat_snprintf.c \
    third_party/PokeMini/libretro/libretro-common/compat/compat_strcasestr.c \
    third_party/PokeMini/libretro/libretro-common/compat/compat_strl.c \
    third_party/PokeMini/libretro/libretro-common/compat/fopen_utf8.c \
    third_party/PokeMini/libretro/libretro-common/encodings/encoding_utf.c \
    third_party/PokeMini/libretro/libretro-common/file/file_path.c \
    third_party/PokeMini/libretro/libretro-common/file/file_path_io.c \
    third_party/PokeMini/libretro/libretro-common/streams/file_stream.c \
    third_party/PokeMini/libretro/libretro-common/streams/file_stream_transforms.c \
    third_party/PokeMini/libretro/libretro-common/streams/memory_stream.c \
    third_party/PokeMini/libretro/libretro-common/string/stdstring.c \
    third_party/PokeMini/libretro/libretro-common/time/rtime.c \
    third_party/PokeMini/libretro/libretro-common/vfs/vfs_implementation.c

pokemini_DEFINES := \
    -DNDEBUG -D__LIBRETRO__

pokemini_INCLUDES := \
    -Ithird_party/PokeMini/libretro \
    -Ithird_party/PokeMini/libretro/libretro-common/include \
    -Ithird_party/PokeMini/source \
    -Ithird_party/PokeMini/resource \
    -Ithird_party/PokeMini/freebios

