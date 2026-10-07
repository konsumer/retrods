# SPDX-License-Identifier: Zlib
#
# Generated from third_party/gambatte-libretro/Makefile.libretro by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

gambatte_DIR := third_party/gambatte-libretro
gambatte_EXTS := gb gbc

gambatte_SRCS := \
    third_party/gambatte-libretro/libgambatte/libretro/gambatte_log.c \
    third_party/gambatte-libretro/libgambatte/libretro/blipper.c \
    third_party/gambatte-libretro/libgambatte/libretro/cc_resampler.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/compat/compat_posix_string.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/compat/compat_snprintf.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/compat/compat_strcasestr.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/compat/compat_strl.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/compat/fopen_utf8.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/encodings/encoding_utf.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/file/file_path.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/file/file_path_io.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/streams/file_stream.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/streams/file_stream_transforms.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/string/stdstring.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/time/rtime.c \
    third_party/gambatte-libretro/libgambatte/libretro-common/vfs/vfs_implementation.c

gambatte_CXX_SRCS := \
    third_party/gambatte-libretro/libgambatte/src/bootloader.cpp \
    third_party/gambatte-libretro/libgambatte/src/cpu.cpp \
    third_party/gambatte-libretro/libgambatte/src/gambatte.cpp \
    third_party/gambatte-libretro/libgambatte/src/initstate.cpp \
    third_party/gambatte-libretro/libgambatte/src/interrupter.cpp \
    third_party/gambatte-libretro/libgambatte/src/interruptrequester.cpp \
    third_party/gambatte-libretro/libgambatte/src/gambatte-memory.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound.cpp \
    third_party/gambatte-libretro/libgambatte/src/statesaver.cpp \
    third_party/gambatte-libretro/libgambatte/src/tima.cpp \
    third_party/gambatte-libretro/libgambatte/src/video.cpp \
    third_party/gambatte-libretro/libgambatte/src/video_libretro.cpp \
    third_party/gambatte-libretro/libgambatte/src/mem/cartridge.cpp \
    third_party/gambatte-libretro/libgambatte/src/mem/cartridge_libretro.cpp \
    third_party/gambatte-libretro/libgambatte/src/mem/huc3.cpp \
    third_party/gambatte-libretro/libgambatte/src/mem/memptrs.cpp \
    third_party/gambatte-libretro/libgambatte/src/mem/rtc.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound/channel1.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound/channel2.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound/channel3.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound/channel4.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound/duty_unit.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound/envelope_unit.cpp \
    third_party/gambatte-libretro/libgambatte/src/sound/length_counter.cpp \
    third_party/gambatte-libretro/libgambatte/src/video/ly_counter.cpp \
    third_party/gambatte-libretro/libgambatte/src/video/lyc_irq.cpp \
    third_party/gambatte-libretro/libgambatte/src/video/next_m0_time.cpp \
    third_party/gambatte-libretro/libgambatte/src/video/ppu.cpp \
    third_party/gambatte-libretro/libgambatte/src/video/sprite_mapper.cpp \
    third_party/gambatte-libretro/libgambatte/libretro/libretro.cpp \
    third_party/gambatte-libretro/libgambatte/libretro/net_serial.cpp

gambatte_DEFINES := \
    -DCC_RESAMPLER_NO_HIGHPASS -DHAVE_INTTYPES_H -DHAVE_NETWORK -DHAVE_STDINT_H -DNDEBUG -DVIDEO_RGB565 -D__LIBRETRO__

gambatte_INCLUDES := \
    -Ithird_party/gambatte-libretro/libgambatte/src \
    -Ithird_party/gambatte-libretro/libgambatte/include \
    -Ithird_party/gambatte-libretro/common \
    -Ithird_party/gambatte-libretro/common/resample \
    -Ithird_party/gambatte-libretro/libgambatte/libretro \
    -Ithird_party/gambatte-libretro/libgambatte/libretro-common/include

