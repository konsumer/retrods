# SPDX-License-Identifier: Zlib
#
# Generated from third_party/ti99-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

ti99_DIR := third_party/ti99-libretro
ti99_EXTS := ctg bin g

ti99_CXX_SRCS := \
    third_party/ti99-libretro/upstream/src/core/arcfs.cpp \
    third_party/ti99-libretro/upstream/src/core/cartridge.cpp \
    third_party/ti99-libretro/upstream/src/core/cBaseObject.cpp \
    third_party/ti99-libretro/upstream/src/core/compress.cpp \
    third_party/ti99-libretro/upstream/src/core/decodelzw.cpp \
    third_party/ti99-libretro/upstream/src/core/device.cpp \
    third_party/ti99-libretro/upstream/src/core/disassemble.cpp \
    third_party/ti99-libretro/upstream/src/core/diskfs.cpp \
    third_party/ti99-libretro/upstream/src/core/diskio.cpp \
    third_party/ti99-libretro/upstream/src/core/encodelzw.cpp \
    third_party/ti99-libretro/upstream/src/core/fileio.cpp \
    third_party/ti99-libretro/upstream/src/core/fs.cpp \
    third_party/ti99-libretro/upstream/src/core/opcodes.cpp \
    third_party/ti99-libretro/upstream/src/core/option.cpp \
    third_party/ti99-libretro/upstream/src/core/pseudofs.cpp \
    third_party/ti99-libretro/upstream/src/core/support.cpp \
    third_party/ti99-libretro/upstream/src/core/ti-disk.cpp \
    third_party/ti99-libretro/upstream/src/core/ti994a.cpp \
    third_party/ti99-libretro/upstream/src/core/tms5220.cpp \
    third_party/ti99-libretro/upstream/src/core/tms9900.cpp \
    third_party/ti99-libretro/upstream/src/core/tms9901.cpp \
    third_party/ti99-libretro/upstream/src/core/tms9918a.cpp \
    third_party/ti99-libretro/upstream/src/core/tms9919.cpp \
    third_party/ti99-libretro/src/libretro.cpp

ti99_INCLUDES := \
    -Ithird_party/ti99-libretro/include \
    -Ithird_party/ti99-libretro/compat \
    -Ithird_party/ti99-libretro/upstream/include

