# SPDX-License-Identifier: Zlib
#
# Generated from third_party/libretro-vecx/Makefile.libretro by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

vecx_DIR := third_party/libretro-vecx
vecx_EXTS := vec

vecx_SRCS := \
    third_party/libretro-vecx/e6809.c \
    third_party/libretro-vecx/vecx_psg.c \
    third_party/libretro-vecx/libretro.c \
    third_party/libretro-vecx/vecx.c \
    third_party/libretro-vecx/libretro-common/glsym/rglgen.c \
    third_party/libretro-vecx/libretro-common/glsym/glsym_gl.c

vecx_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DHAS_GPU -DHAVE_INTTYPES_H -DHAVE_STDINT_H -DHAVE_STRINGS_H -DINLINE=inline -DNDEBUG -D__LIBRETRO__

vecx_INCLUDES := \
    -Ithird_party/libretro-vecx \
    -Ithird_party/libretro-vecx/libretro-common/include

