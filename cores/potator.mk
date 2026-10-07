# SPDX-License-Identifier: Zlib
#
# Generated from third_party/Potator/platform/libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

potator_DIR := third_party/Potator/platform/libretro
potator_EXTS := sv

potator_SRCS := \
    third_party/Potator/platform/libretro/libretro.c \
    third_party/Potator/common/controls.c \
    third_party/Potator/common/gpu.c \
    third_party/Potator/common/memorymap.c \
    third_party/Potator/common/sound.c \
    third_party/Potator/common/timer.c \
    third_party/Potator/common/watara.c \
    third_party/Potator/common/m6502/m6502.c

potator_DEFINES := \
    -DNDEBUG -D__LIBRETRO__

potator_INCLUDES := \
    -Ithird_party/Potator/common \
    -Ithird_party/Potator/common/m6502 \
    -Ithird_party/Potator/platform/libretro \
    -Ithird_party/Potator/platform/libretro/libretro-common/include

