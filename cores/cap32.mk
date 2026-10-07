# SPDX-License-Identifier: Zlib
#
# Generated from third_party/libretro-cap32/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

cap32_DIR := third_party/libretro-cap32
cap32_EXTS := cpc d64 t64 tap sna

cap32_SRCS := \
    third_party/libretro-cap32/libretro/libretro-core.c \
    third_party/libretro-cap32/cap32/cap32.c \
    third_party/libretro-cap32/cap32/slots.c \
    third_party/libretro-cap32/cap32/crtc.c \
    third_party/libretro-cap32/cap32/fdc.c \
    third_party/libretro-cap32/cap32/psg.c \
    third_party/libretro-cap32/cap32/tape.c \
    third_party/libretro-cap32/cap32/cart.c \
    third_party/libretro-cap32/cap32/asic.c \
    third_party/libretro-cap32/cap32/z80.c \
    third_party/libretro-cap32/cap32/kbdauto.c \
    third_party/libretro-cap32/cap32/lightgun/lightgun.c \
    third_party/libretro-cap32/cap32/lightgun/gunstick.c \
    third_party/libretro-cap32/cap32/lightgun/phaser.c \
    third_party/libretro-cap32/libretro/microui/microui.c \
    third_party/libretro-cap32/libretro/db/database.c \
    third_party/libretro-cap32/libretro/dsk/loader.c \
    third_party/libretro-cap32/libretro/dsk/format.c \
    third_party/libretro-cap32/libretro/dsk/amsdos_catalog.c \
    third_party/libretro-cap32/libretro/gfx/software.c \
    third_party/libretro-cap32/libretro/gfx/video.c \
    third_party/libretro-cap32/libretro/gfx/video8bpp.c \
    third_party/libretro-cap32/libretro/gfx/video16bpp.c \
    third_party/libretro-cap32/libretro/gfx/video24bpp.c \
    third_party/libretro-cap32/libretro/assets/ui_keyboard_bg_crop.c \
    third_party/libretro-cap32/libretro/assets/ui_keyboard_bg.c \
    third_party/libretro-cap32/libretro/assets/ui_keyboard_en.c \
    third_party/libretro-cap32/libretro/assets/ui_keyboard_es.c \
    third_party/libretro-cap32/libretro/assets/ui_keyboard_fr.c \
    third_party/libretro-cap32/libretro/assets/font.c \
    third_party/libretro-cap32/libretro/retro_strings.c \
    third_party/libretro-cap32/libretro/retro_utils.c \
    third_party/libretro-cap32/libretro/retro_disk_control.c \
    third_party/libretro-cap32/libretro/retro_events.c \
    third_party/libretro-cap32/libretro/retro_snd.c \
    third_party/libretro-cap32/libretro/retro_render.c \
    third_party/libretro-cap32/libretro/retro_ui.c \
    third_party/libretro-cap32/libretro/retro_gun.c \
    third_party/libretro-cap32/libretro/retro_keyboard.c \
    third_party/libretro-cap32/libretro-common/file/file_path.c \
    third_party/libretro-cap32/libretro-common/file/file_path_io.c \
    third_party/libretro-cap32/libretro-common/file/retro_dirent.c \
    third_party/libretro-cap32/libretro-common/streams/file_stream.c \
    third_party/libretro-cap32/libretro-common/streams/file_stream_transforms.c \
    third_party/libretro-cap32/libretro-common/vfs/vfs_implementation.c \
    third_party/libretro-cap32/libretro-common/string/stdstring.c \
    third_party/libretro-cap32/libretro-common/compat/compat_strl.c \
    third_party/libretro-cap32/libretro-common/compat/fopen_utf8.c \
    third_party/libretro-cap32/libretro-common/encodings/encoding_utf.c \
    third_party/libretro-cap32/libretro-common/time/rtime.c \
    third_party/libretro-cap32/libretro-common/memmap/memalign.c

cap32_DEFINES := \
    -DHAVE_CONFIG_H -DINLINE=inline -D__LIBRETRO__

cap32_INCLUDES := \
    -Ithird_party/libretro-cap32 \
    -Ithird_party/libretro-cap32/cap32 \
    -Ithird_party/libretro-cap32/libretro \
    -Ithird_party/libretro-cap32/libretro/microui \
    -Ithird_party/libretro-cap32/libretro-common/include

