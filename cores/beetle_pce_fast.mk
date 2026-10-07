# SPDX-License-Identifier: Zlib
#
# Generated from third_party/beetle-pce-fast-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

beetle_pce_fast_DIR := third_party/beetle-pce-fast-libretro
beetle_pce_fast_EXTS := pce sgx

beetle_pce_fast_SRCS := \
    third_party/beetle-pce-fast-libretro/mednafen/hw_misc/arcade_card/arcade_card.c \
    third_party/beetle-pce-fast-libretro/mednafen/pce_fast/pcecd_drive.c \
    third_party/beetle-pce-fast-libretro/mednafen/pce_fast/pcecd.c \
    third_party/beetle-pce-fast-libretro/mednafen/pce_fast/psg.c \
    third_party/beetle-pce-fast-libretro/mednafen/pce_fast/huc6280.c \
    third_party/beetle-pce-fast-libretro/mednafen/pce_fast/input.c \
    third_party/beetle-pce-fast-libretro/mednafen/pce_fast/vdc.c \
    third_party/beetle-pce-fast-libretro/mednafen/sound/Blip_Buffer.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/CDAccess.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/CDAccess_Image.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/CDAccess_CCD.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/audioreader.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/cdromif.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/CDUtility.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/lec.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/galois.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/l-ec.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/edc_crc32.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdrom/recover-raw.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/bitwise.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/block.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/codebook.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/floor0.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/floor1.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/framing.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/info.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/mapping0.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/mdct.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/registry.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/res012.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/sharedbook.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/synthesis.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/vorbisfile.c \
    third_party/beetle-pce-fast-libretro/mednafen/tremor/window.c \
    third_party/beetle-pce-fast-libretro/libretro.c \
    third_party/beetle-pce-fast-libretro/mednafen/general.c \
    third_party/beetle-pce-fast-libretro/mednafen/cdstream.c \
    third_party/beetle-pce-fast-libretro/mednafen/mempatcher.c \
    third_party/beetle-pce-fast-libretro/mednafen/okiadpcm.c \
    third_party/beetle-pce-fast-libretro/mednafen/file.c \
    third_party/beetle-pce-fast-libretro/mednafen/settings.c \
    third_party/beetle-pce-fast-libretro/mednafen/state.c \
    third_party/beetle-pce-fast-libretro/mednafen/mednafen-endian.c \
    third_party/beetle-pce-fast-libretro/libretro-common/streams/file_stream.c \
    third_party/beetle-pce-fast-libretro/libretro-common/streams/file_stream_transforms.c \
    third_party/beetle-pce-fast-libretro/libretro-common/file/file_path.c \
    third_party/beetle-pce-fast-libretro/libretro-common/file/retro_dirent.c \
    third_party/beetle-pce-fast-libretro/libretro-common/lists/string_list.c \
    third_party/beetle-pce-fast-libretro/libretro-common/lists/dir_list.c \
    third_party/beetle-pce-fast-libretro/libretro-common/compat/compat_strl.c \
    third_party/beetle-pce-fast-libretro/libretro-common/compat/compat_snprintf.c \
    third_party/beetle-pce-fast-libretro/libretro-common/compat/compat_posix_string.c \
    third_party/beetle-pce-fast-libretro/libretro-common/compat/compat_strcasestr.c \
    third_party/beetle-pce-fast-libretro/libretro-common/compat/fopen_utf8.c \
    third_party/beetle-pce-fast-libretro/libretro-common/encodings/encoding_utf.c \
    third_party/beetle-pce-fast-libretro/libretro-common/encodings/encoding_crc32.c \
    third_party/beetle-pce-fast-libretro/libretro-common/memmap/memalign.c \
    third_party/beetle-pce-fast-libretro/libretro-common/string/stdstring.c \
    third_party/beetle-pce-fast-libretro/libretro-common/time/rtime.c \
    third_party/beetle-pce-fast-libretro/libretro-common/vfs/vfs_implementation.c

beetle_pce_fast_DEFINES := \
    -DFRONTEND_SUPPORTS_RGB565 -DINLINE=inline -DMEDNAFEN_VERSION_NUMERIC=931 -DNDEBUG -DNEED_CD -DNEED_TREMOR -DSTDC_HEADERS -DUSE_CHEATS -DWANT_PCE_FAST_EMU -D_LOW_ACCURACY_ -D__LIBRETRO__ -D__STDC_LIMIT_MACROS

beetle_pce_fast_INCLUDES := \
    -Ithird_party/beetle-pce-fast-libretro \
    -Ithird_party/beetle-pce-fast-libretro/mednafen \
    -Ithird_party/beetle-pce-fast-libretro/mednafen/include \
    -Ithird_party/beetle-pce-fast-libretro/mednafen/hw_sound \
    -Ithird_party/beetle-pce-fast-libretro/mednafen/hw_cpu \
    -Ithird_party/beetle-pce-fast-libretro/mednafen/hw_misc \
    -Ithird_party/beetle-pce-fast-libretro/libretro-common/include

