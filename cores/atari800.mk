# SPDX-License-Identifier: Zlib
#
# Generated from third_party/libretro-atari800/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

atari800_DIR := third_party/libretro-atari800
atari800_EXTS := atr xex car bin rom a52

atari800_SRCS := \
    third_party/libretro-atari800/libretro/libretro-common/streams/memory_stream.c \
    third_party/libretro-atari800/libretro/libretro-common/compat/compat_strl.c \
    third_party/libretro-atari800/libretro/libretro-common/compat/compat_strcasestr.c \
    third_party/libretro-atari800/libretro/libretro-common/compat/fopen_utf8.c \
    third_party/libretro-atari800/libretro/libretro-common/encodings/encoding_utf.c \
    third_party/libretro-atari800/libretro/libretro-common/file/file_path.c \
    third_party/libretro-atari800/libretro/libretro-common/file/file_path_io.c \
    third_party/libretro-atari800/libretro/libretro-common/string/stdstring.c \
    third_party/libretro-atari800/libretro/libretro-common/time/rtime.c \
    third_party/libretro-atari800/libretro/libretro-common/vfs/vfs_implementation.c \
    third_party/libretro-atari800/libretro/carts_hash.c \
    third_party/libretro-atari800/libretro/libretro-core.c \
    third_party/libretro-atari800/libretro/core-mapper.c \
    third_party/libretro-atari800/libretro/graph.c \
    third_party/libretro-atari800/libretro/vkbd.c \
    third_party/libretro-atari800/libretro/retro_strings.c \
    third_party/libretro-atari800/libretro/retro_utils.c \
    third_party/libretro-atari800/libretro/retro_disk_control.c \
    third_party/libretro-atari800/libretro/retro_vfs.c \
    third_party/libretro-atari800/atari800/src/afile.c \
    third_party/libretro-atari800/atari800/src/antic.c \
    third_party/libretro-atari800/atari800/src/atari.c \
    third_party/libretro-atari800/atari800/src/binload.c \
    third_party/libretro-atari800/atari800/src/cartridge.c \
    third_party/libretro-atari800/atari800/src/cassette.c \
    third_party/libretro-atari800/atari800/src/compfile.c \
    third_party/libretro-atari800/atari800/src/cfg.c \
    third_party/libretro-atari800/atari800/src/cpu.c \
    third_party/libretro-atari800/atari800/src/crc32.c \
    third_party/libretro-atari800/atari800/src/devices.c \
    third_party/libretro-atari800/atari800/src/cartridge_info.c \
    third_party/libretro-atari800/atari800/src/esc.c \
    third_party/libretro-atari800/atari800/src/gtia.c \
    third_party/libretro-atari800/atari800/src/img_tape.c \
    third_party/libretro-atari800/atari800/src/log.c \
    third_party/libretro-atari800/atari800/src/memory.c \
    third_party/libretro-atari800/atari800/src/monitor.c \
    third_party/libretro-atari800/atari800/src/pbi.c \
    third_party/libretro-atari800/atari800/src/pia.c \
    third_party/libretro-atari800/atari800/src/pokey.c \
    third_party/libretro-atari800/atari800/src/pokeysnd.c \
    third_party/libretro-atari800/atari800/src/mzpokeysnd.c \
    third_party/libretro-atari800/atari800/src/remez.c \
    third_party/libretro-atari800/atari800/src/rtime.c \
    third_party/libretro-atari800/atari800/src/sio.c \
    third_party/libretro-atari800/atari800/src/sysrom.c \
    third_party/libretro-atari800/atari800/src/util.c \
    third_party/libretro-atari800/atari800/src/sound.c \
    third_party/libretro-atari800/atari800/src/pbi_proto80.c \
    third_party/libretro-atari800/atari800/src/af80.c \
    third_party/libretro-atari800/atari800/src/input.c \
    third_party/libretro-atari800/atari800/src/statesav.c \
    third_party/libretro-atari800/atari800/src/ui_basic.c \
    third_party/libretro-atari800/atari800/src/ui.c \
    third_party/libretro-atari800/atari800/src/artifact.c \
    third_party/libretro-atari800/atari800/src/colours.c \
    third_party/libretro-atari800/atari800/src/colours_ntsc.c \
    third_party/libretro-atari800/atari800/src/colours_pal.c \
    third_party/libretro-atari800/atari800/src/colours_external.c \
    third_party/libretro-atari800/atari800/src/screen.c \
    third_party/libretro-atari800/atari800/src/cycle_map.c \
    third_party/libretro-atari800/atari800/src/pbi_mio.c \
    third_party/libretro-atari800/atari800/src/pbi_bb.c \
    third_party/libretro-atari800/atari800/src/pbi_scsi.c \
    third_party/libretro-atari800/atari800/src/ide.c \
    third_party/libretro-atari800/atari800/src/xep80.c \
    third_party/libretro-atari800/atari800/src/xep80_fonts.c \
    third_party/libretro-atari800/atari800/src/file_export.c \
    third_party/libretro-atari800/atari800/src/filter_ntsc.c \
    third_party/libretro-atari800/atari800/src/atari_ntsc/atari_ntsc.c \
    third_party/libretro-atari800/libretro/platform.c \
    third_party/libretro-atari800/atari800/src/roms/altirraos_xl.c \
    third_party/libretro-atari800/atari800/src/roms/altirraos_800.c \
    third_party/libretro-atari800/atari800/src/roms/altirra_basic.c \
    third_party/libretro-atari800/atari800/src/roms/altirra_5200_os.c \
    third_party/libretro-atari800/atari800/src/roms/altirra_5200_charset.c \
    third_party/libretro-atari800/deps/zlib/adler32.c \
    third_party/libretro-atari800/deps/zlib/crc32.c \
    third_party/libretro-atari800/deps/zlib/deflate.c \
    third_party/libretro-atari800/deps/zlib/gzclose.c \
    third_party/libretro-atari800/deps/zlib/gzlib.c \
    third_party/libretro-atari800/deps/zlib/gzread.c \
    third_party/libretro-atari800/deps/zlib/gzwrite.c \
    third_party/libretro-atari800/deps/zlib/inffast.c \
    third_party/libretro-atari800/deps/zlib/inflate.c \
    third_party/libretro-atari800/deps/zlib/inftrees.c \
    third_party/libretro-atari800/deps/zlib/trees.c \
    third_party/libretro-atari800/deps/zlib/zutil.c

atari800_DEFINES := \
    -DHAVE_CONFIG_H -DINLINE=inline -DNDEBUG -D__LIBRETRO__

atari800_INCLUDES := \
    -Ithird_party/libretro-atari800 \
    -Ithird_party/libretro-atari800/atari800/src \
    -Ithird_party/libretro-atari800/libretro \
    -Ithird_party/libretro-atari800/libretro/libretro-common/include \
    -Ithird_party/libretro-atari800/libretro/libretro-common/include/compat/zlib \
    -Ithird_party/libretro-atari800/deps/zlib

