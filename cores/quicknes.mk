# SPDX-License-Identifier: Zlib
#
# Generated from third_party/QuickNES_Core/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

quicknes_DIR := third_party/QuickNES_Core
quicknes_EXTS := nes fds

quicknes_CXX_SRCS := \
    third_party/QuickNES_Core/libretro/libretro.cpp \
    third_party/QuickNES_Core/nes_emu/abstract_file.cpp \
    third_party/QuickNES_Core/nes_emu/apu_state.cpp \
    third_party/QuickNES_Core/nes_emu/Blip_Buffer.cpp \
    third_party/QuickNES_Core/nes_emu/Effects_Buffer.cpp \
    third_party/QuickNES_Core/nes_emu/Multi_Buffer.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Apu.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Buffer.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Cart.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Core.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Cpu.cpp \
    third_party/QuickNES_Core/nes_emu/nes_data.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Effects_Buffer.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Emu.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_File.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Fme7_Apu.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Mapper.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Vrc7.cpp \
    third_party/QuickNES_Core/nes_emu/emu2413.cpp \
    third_party/QuickNES_Core/nes_emu/emu2413_state.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Namco_Apu.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Oscs.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Ppu.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Ppu_Impl.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Ppu_Rendering.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_State.cpp \
    third_party/QuickNES_Core/nes_emu/nes_util.cpp \
    third_party/QuickNES_Core/nes_emu/Nes_Vrc6_Apu.cpp \
    third_party/QuickNES_Core/nes_emu/Data_Reader.cpp \
    third_party/QuickNES_Core/nes_emu/nes_ntsc.cpp

quicknes_DEFINES := \
    -DNDEBUG -D__LIBRETRO__

quicknes_INCLUDES := \
    -Ithird_party/QuickNES_Core \
    -Ithird_party/QuickNES_Core/nes_emu \
    -Ithird_party/QuickNES_Core/libretro \
    -Ithird_party/QuickNES_Core/libretro/libretro-common/include

