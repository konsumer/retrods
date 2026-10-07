# SPDX-License-Identifier: Zlib
#
# Generated from third_party/beetle-vb-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

beetle_vb_DIR := third_party/beetle-vb-libretro
beetle_vb_EXTS := vb vboy

beetle_vb_SRCS := \
    third_party/beetle-vb-libretro/mednafen/vb/vsu.c \
    third_party/beetle-vb-libretro/mednafen/vb/input.c \
    third_party/beetle-vb-libretro/mednafen/vb/timer.c \
    third_party/beetle-vb-libretro/mednafen/vb/vip.c \
    third_party/beetle-vb-libretro/mednafen/hw_cpu/v810/fpu-new/softfloat.c \
    third_party/beetle-vb-libretro/mednafen/sound/Blip_Buffer.c \
    third_party/beetle-vb-libretro/mednafen/state.c \
    third_party/beetle-vb-libretro/mednafen/settings.c \
    third_party/beetle-vb-libretro/libretro-common/compat/compat_strl.c \
    third_party/beetle-vb-libretro/libretro-common/compat/compat_snprintf.c

beetle_vb_CXX_SRCS := \
    third_party/beetle-vb-libretro/mednafen/hw_cpu/v810/v810_cpu.cpp \
    third_party/beetle-vb-libretro/mednafen/mempatcher.cpp \
    third_party/beetle-vb-libretro/libretro.cpp

beetle_vb_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DINLINE=inline -DMEDNAFEN_VERSION_NUMERIC=931 -DNDEBUG -DSTDC_HEADERS -DWANT_32BPP -D__LIBRETRO__ -D__STDC_LIMIT_MACROS

beetle_vb_INCLUDES := \
    -Ithird_party/beetle-vb-libretro \
    -Ithird_party/beetle-vb-libretro/mednafen \
    -Ithird_party/beetle-vb-libretro/mednafen/include \
    -Ithird_party/beetle-vb-libretro/mednafen/hw_sound \
    -Ithird_party/beetle-vb-libretro/mednafen/hw_cpu \
    -Ithird_party/beetle-vb-libretro/mednafen/hw_misc \
    -Ithird_party/beetle-vb-libretro/libretro-common/include

