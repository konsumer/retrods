# SPDX-License-Identifier: Zlib
#
# Generated from third_party/gw-libretro/Makefile.libretro by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

gw_DIR := third_party/gw-libretro
gw_EXTS := mgw gw

gw_SRCS := \
    third_party/gw-libretro/src/libretro.c \
    third_party/gw-libretro/src/libretro_version.c \
    third_party/gw-libretro/src/missing.c \
    third_party/gw-libretro/gwrom/gwrom.c \
    third_party/gw-libretro/gwlua/bsreader.c \
    third_party/gw-libretro/gwlua/functions.c \
    third_party/gw-libretro/gwlua/gwlua.c \
    third_party/gw-libretro/gwlua/image.c \
    third_party/gw-libretro/gwlua/ref.c \
    third_party/gw-libretro/gwlua/sound.c \
    third_party/gw-libretro/gwlua/timer.c \
    third_party/gw-libretro/retroluxury/src/rl_backgrnd.c \
    third_party/gw-libretro/retroluxury/src/rl_image.c \
    third_party/gw-libretro/retroluxury/src/rl_map.c \
    third_party/gw-libretro/retroluxury/src/rl_rand.c \
    third_party/gw-libretro/retroluxury/src/rl_sound.c \
    third_party/gw-libretro/retroluxury/src/rl_sprite.c \
    third_party/gw-libretro/retroluxury/src/rl_tile.c \
    third_party/gw-libretro/retroluxury/src/rl_version.c \
    third_party/gw-libretro/bzip2/blocksort.c \
    third_party/gw-libretro/bzip2/huffman.c \
    third_party/gw-libretro/bzip2/crctable.c \
    third_party/gw-libretro/bzip2/randtable.c \
    third_party/gw-libretro/bzip2/compress.c \
    third_party/gw-libretro/bzip2/decompress.c \
    third_party/gw-libretro/bzip2/bzlib.c \
    third_party/gw-libretro/lua/src/lapi.c \
    third_party/gw-libretro/lua/src/lcode.c \
    third_party/gw-libretro/lua/src/lctype.c \
    third_party/gw-libretro/lua/src/ldebug.c \
    third_party/gw-libretro/lua/src/ldo.c \
    third_party/gw-libretro/lua/src/ldump.c \
    third_party/gw-libretro/lua/src/lfunc.c \
    third_party/gw-libretro/lua/src/lgc.c \
    third_party/gw-libretro/lua/src/llex.c \
    third_party/gw-libretro/lua/src/lmem.c \
    third_party/gw-libretro/lua/src/lobject.c \
    third_party/gw-libretro/lua/src/lopcodes.c \
    third_party/gw-libretro/lua/src/lparser.c \
    third_party/gw-libretro/lua/src/lstate.c \
    third_party/gw-libretro/lua/src/lstring.c \
    third_party/gw-libretro/lua/src/ltable.c \
    third_party/gw-libretro/lua/src/ltm.c \
    third_party/gw-libretro/lua/src/lundump.c \
    third_party/gw-libretro/lua/src/lvm.c \
    third_party/gw-libretro/lua/src/lzio.c \
    third_party/gw-libretro/lua/src/lauxlib.c \
    third_party/gw-libretro/lua/src/lbaselib.c \
    third_party/gw-libretro/lua/src/lbitlib.c \
    third_party/gw-libretro/lua/src/lcorolib.c \
    third_party/gw-libretro/lua/src/ldblib.c \
    third_party/gw-libretro/lua/src/lmathlib.c \
    third_party/gw-libretro/lua/src/lstrlib.c \
    third_party/gw-libretro/lua/src/ltablib.c \
    third_party/gw-libretro/lua/src/lutf8lib.c \
    third_party/gw-libretro/lua/src/loadlib.c

gw_DEFINES := \
    -DBZ_NO_STDIO -DNDEBUG -D__LIBRETRO__ -Dgwlua_free=free -Dgwlua_malloc=malloc -Dgwlua_realloc=realloc -Dgwrom_free=free -Dgwrom_malloc=malloc -Drl_free=free -Drl_malloc=malloc

gw_INCLUDES := \
    -Ithird_party/gw-libretro \
    -Ithird_party/gw-libretro/src \
    -Ithird_party/gw-libretro/gwrom \
    -Ithird_party/gw-libretro/gwlua \
    -Ithird_party/gw-libretro/bzip2 \
    -Ithird_party/gw-libretro/lua/src \
    -Ithird_party/gw-libretro/retroluxury/src

