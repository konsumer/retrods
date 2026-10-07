# SPDX-License-Identifier: Zlib
#
# Generated from third_party/Genesis-Plus-GX/Makefile.libretro by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

genesis_plus_gx_DIR := third_party/Genesis-Plus-GX
genesis_plus_gx_EXTS := gen md bin smd

genesis_plus_gx_SRCS := \
    third_party/Genesis-Plus-GX/core/genesis.c \
    third_party/Genesis-Plus-GX/core/io_ctrl.c \
    third_party/Genesis-Plus-GX/core/loadrom.c \
    third_party/Genesis-Plus-GX/core/mem68k.c \
    third_party/Genesis-Plus-GX/core/membnk.c \
    third_party/Genesis-Plus-GX/core/memz80.c \
    third_party/Genesis-Plus-GX/core/state.c \
    third_party/Genesis-Plus-GX/core/system.c \
    third_party/Genesis-Plus-GX/core/vdp_ctrl.c \
    third_party/Genesis-Plus-GX/core/vdp_render.c \
    third_party/Genesis-Plus-GX/core/z80/z80.c \
    third_party/Genesis-Plus-GX/core/m68k/m68kcpu.c \
    third_party/Genesis-Plus-GX/core/m68k/s68kcpu.c \
    third_party/Genesis-Plus-GX/core/ntsc/md_ntsc.c \
    third_party/Genesis-Plus-GX/core/ntsc/sms_ntsc.c \
    third_party/Genesis-Plus-GX/core/sound/blip_buf.c \
    third_party/Genesis-Plus-GX/core/sound/eq.c \
    third_party/Genesis-Plus-GX/core/sound/opll.c \
    third_party/Genesis-Plus-GX/core/sound/psg.c \
    third_party/Genesis-Plus-GX/core/sound/sound.c \
    third_party/Genesis-Plus-GX/core/sound/ym2413.c \
    third_party/Genesis-Plus-GX/core/sound/ym2612.c \
    third_party/Genesis-Plus-GX/core/sound/ym3438.c \
    third_party/Genesis-Plus-GX/core/input_hw/activator.c \
    third_party/Genesis-Plus-GX/core/input_hw/gamepad.c \
    third_party/Genesis-Plus-GX/core/input_hw/graphic_board.c \
    third_party/Genesis-Plus-GX/core/input_hw/input.c \
    third_party/Genesis-Plus-GX/core/input_hw/lightgun.c \
    third_party/Genesis-Plus-GX/core/input_hw/mouse.c \
    third_party/Genesis-Plus-GX/core/input_hw/paddle.c \
    third_party/Genesis-Plus-GX/core/input_hw/smash.c \
    third_party/Genesis-Plus-GX/core/input_hw/sportspad.c \
    third_party/Genesis-Plus-GX/core/input_hw/teamplayer.c \
    third_party/Genesis-Plus-GX/core/input_hw/terebi_oekaki.c \
    third_party/Genesis-Plus-GX/core/input_hw/xe_1ap.c \
    third_party/Genesis-Plus-GX/core/cd_hw/cd_cart.c \
    third_party/Genesis-Plus-GX/core/cd_hw/cdc.c \
    third_party/Genesis-Plus-GX/core/cd_hw/cdd.c \
    third_party/Genesis-Plus-GX/core/cd_hw/gfx.c \
    third_party/Genesis-Plus-GX/core/cd_hw/pcm.c \
    third_party/Genesis-Plus-GX/core/cd_hw/scd.c \
    third_party/Genesis-Plus-GX/core/cart_hw/areplay.c \
    third_party/Genesis-Plus-GX/core/cart_hw/eeprom_93c.c \
    third_party/Genesis-Plus-GX/core/cart_hw/eeprom_i2c.c \
    third_party/Genesis-Plus-GX/core/cart_hw/eeprom_spi.c \
    third_party/Genesis-Plus-GX/core/cart_hw/flash_cfi.c \
    third_party/Genesis-Plus-GX/core/cart_hw/ggenie.c \
    third_party/Genesis-Plus-GX/core/cart_hw/md_cart.c \
    third_party/Genesis-Plus-GX/core/cart_hw/megasd.c \
    third_party/Genesis-Plus-GX/core/cart_hw/sms_cart.c \
    third_party/Genesis-Plus-GX/core/cart_hw/sram.c \
    third_party/Genesis-Plus-GX/core/cart_hw/yx5200.c \
    third_party/Genesis-Plus-GX/core/cart_hw/svp/ssp16.c \
    third_party/Genesis-Plus-GX/core/cart_hw/svp/svp.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/streams/file_stream.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/streams/file_stream_transforms.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/compat/fopen_utf8.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/compat/compat_snprintf.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/compat/compat_strl.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/compat/compat_strcasestr.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/compat/compat_posix_string.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/encodings/encoding_utf.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/file/file_path.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/file/retro_dirent.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/lists/string_list.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/lists/dir_list.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/memmap/memalign.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/string/stdstring.c \
    third_party/Genesis-Plus-GX/libretro/libretro-common/vfs/vfs_implementation.c \
    third_party/Genesis-Plus-GX/libretro/deps/zlib-1.2.11/adler32.c \
    third_party/Genesis-Plus-GX/libretro/deps/zlib-1.2.11/crc32.c \
    third_party/Genesis-Plus-GX/libretro/deps/zlib-1.2.11/inffast.c \
    third_party/Genesis-Plus-GX/libretro/deps/zlib-1.2.11/inflate.c \
    third_party/Genesis-Plus-GX/libretro/deps/zlib-1.2.11/inftrees.c \
    third_party/Genesis-Plus-GX/libretro/deps/zlib-1.2.11/zutil.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/bitwise.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/block.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/codebook.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/floor0.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/floor1.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/framing.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/info.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/mapping0.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/mdct.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/registry.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/res012.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/sharedbook.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/synthesis.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/vorbisfile.c \
    third_party/Genesis-Plus-GX/core/sound/tremor/window.c \
    third_party/Genesis-Plus-GX/libretro/libretro.c

genesis_plus_gx_DEFINES := \
    -DBYTE_ORDER=LITTLE_ENDIAN -DFRONTEND_SUPPORTS_RGB565 -DHAVE_OPLL_CORE -DHAVE_YM3438_CORE -DHAVE_ZLIB -DLSB_FIRST -DM68K_OVERCLOCK_SHIFT=20 -DMAXROMSIZE=33554432 -DNDEBUG -DUSE_16BPP_RENDERING -DUSE_LIBRETRO_VFS -DUSE_LIBTREMOR -DUSE_PER_SOUND_CHANNELS_CONFIG -DZ80_OVERCLOCK_SHIFT=20 -D__LIBRETRO__

genesis_plus_gx_INCLUDES := \
    -Ithird_party/Genesis-Plus-GX/core \
    -Ithird_party/Genesis-Plus-GX/core/z80 \
    -Ithird_party/Genesis-Plus-GX/core/m68k \
    -Ithird_party/Genesis-Plus-GX/core/ntsc \
    -Ithird_party/Genesis-Plus-GX/core/sound \
    -Ithird_party/Genesis-Plus-GX/core/sound/minimp3 \
    -Ithird_party/Genesis-Plus-GX/core/input_hw \
    -Ithird_party/Genesis-Plus-GX/core/cd_hw \
    -Ithird_party/Genesis-Plus-GX/core/cart_hw \
    -Ithird_party/Genesis-Plus-GX/core/cart_hw/svp \
    -Ithird_party/Genesis-Plus-GX/libretro \
    -Ithird_party/Genesis-Plus-GX/libretro/libretro-common/include

