# SPDX-License-Identifier: Zlib
#
# Generated from third_party/libretro-o2em/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

o2em_DIR := third_party/libretro-o2em
o2em_EXTS := o2

o2em_SRCS := \
    third_party/libretro-o2em/src/audio.c \
    third_party/libretro-o2em/src/cpu.c \
    third_party/libretro-o2em/src/cset.c \
    third_party/libretro-o2em/src/keyboard.c \
    third_party/libretro-o2em/src/score.c \
    third_party/libretro-o2em/src/table.c \
    third_party/libretro-o2em/src/vdc.c \
    third_party/libretro-o2em/src/vmachine.c \
    third_party/libretro-o2em/src/voice.c \
    third_party/libretro-o2em/src/vpp.c \
    third_party/libretro-o2em/src/vpp_cset.c \
    third_party/libretro-o2em/libretro.c \
    third_party/libretro-o2em/allegrowrapper/wrapalleg.c \
    third_party/libretro-o2em/src/vkeyb/ui.c \
    third_party/libretro-o2em/src/vkeyb/vkeyb.c \
    third_party/libretro-o2em/src/vkeyb/vkeyb_config.c \
    third_party/libretro-o2em/src/vkeyb/vkeyb_layout.c \
    third_party/libretro-o2em/libretro-common/compat/compat_posix_string.c \
    third_party/libretro-o2em/libretro-common/compat/compat_snprintf.c \
    third_party/libretro-o2em/libretro-common/compat/compat_strcasestr.c \
    third_party/libretro-o2em/libretro-common/compat/compat_strl.c \
    third_party/libretro-o2em/libretro-common/compat/fopen_utf8.c \
    third_party/libretro-o2em/libretro-common/encodings/encoding_crc32.c \
    third_party/libretro-o2em/libretro-common/encodings/encoding_utf.c \
    third_party/libretro-o2em/libretro-common/file/file_path.c \
    third_party/libretro-o2em/libretro-common/file/file_path_io.c \
    third_party/libretro-o2em/libretro-common/streams/file_stream.c \
    third_party/libretro-o2em/libretro-common/time/rtime.c \
    third_party/libretro-o2em/libretro-common/vfs/vfs_implementation.c \
    third_party/libretro-o2em/libretro-common/audio/conversion/float_to_s16.c \
    third_party/libretro-o2em/libretro-common/audio/conversion/s16_to_float.c \
    third_party/libretro-o2em/libretro-common/audio/resampler/audio_resampler.c \
    third_party/libretro-o2em/libretro-common/audio/resampler/drivers/sinc_resampler.c \
    third_party/libretro-o2em/libretro-common/features/features_cpu.c \
    third_party/libretro-o2em/libretro-common/file/config_file.c \
    third_party/libretro-o2em/libretro-common/file/config_file_userdata.c \
    third_party/libretro-o2em/libretro-common/formats/wav/rwav.c \
    third_party/libretro-o2em/libretro-common/memmap/memalign.c \
    third_party/libretro-o2em/core_audio_mixer.c

o2em_DEFINES := \
    -DHAVE_RWAV -DHAVE_VOICE -DNDEBUG -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D__LIBRETRO__

o2em_INCLUDES := \
    -Ithird_party/libretro-o2em \
    -Ithird_party/libretro-o2em/src \
    -Ithird_party/libretro-o2em/allegrowrapper \
    -Ithird_party/libretro-o2em/libretro-common/include

