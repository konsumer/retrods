# Sega Mega Drive / Genesis.
#
# INLINE: some units pull libretro-common's retro_inline.h before the core's
# macros.h, leaving INLINE as C99 `inline`. The Z80 opcode table and both FM
# engines then emit globals in every unit that includes them ("multiple
# definition" for the FM pair, "undefined reference" for the Z80 ops). Pinning a
# static specifier on the command line makes both header sets keep their hands
# off; patches/libretro-common/ makes libretro-common accept that.
genesis_plus_gx_CFLAGS := -Wno-incompatible-pointer-types -DINLINE="static __inline__"

# MAXROMSIZE sizes md_cart_t::rom. GPGX itself writes 0xFF padding at offset
# 0x510000 (unmapped-area behaviour), so it must be at least 5.3 MiB.
# cartridges (Super Street Fighter II, the largest, is 5 MiB).
genesis_plus_gx_DEFINES := $(foreach d,$(genesis_plus_gx_DEFINES),$(if $(findstring -DMAXROMSIZE,$(d)),,$(d)))
genesis_plus_gx_DEFINES += -DMAXROMSIZE=6291456

# CHD/CD image support drags in libchdr, zstd and lzma. Mega Drive cartridges do
# not need it, so only zlib (used for crc32) is kept from libretro/deps.
genesis_plus_gx_DEFINES := $(filter-out -DUSE_LIBCHDR,$(genesis_plus_gx_DEFINES))
genesis_plus_gx_drop = $(if $(findstring /libretro/deps/libchdr/,$(1)),,$(if $(findstring /libretro/deps/zstd/,$(1)),,$(if $(findstring /libretro/deps/lzma,$(1)),,$(1))))
genesis_plus_gx_SRCS := $(foreach f,$(genesis_plus_gx_SRCS),$(call genesis_plus_gx_drop,$(f)))
genesis_plus_gx_CXX_SRCS := $(foreach f,$(genesis_plus_gx_CXX_SRCS),$(call genesis_plus_gx_drop,$(f)))
