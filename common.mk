# SPDX-License-Identifier: Zlib
#
# Core configuration. Each core is described by cores/<name>.mk, which sets:
#
#   <name>_DIR       directory the sources live under (relative to repo root)
#   <name>_SRCS      C/C++ sources, prefixed with <name>_DIR
#   <name>_DEFINES   -D flags for this core
#   <name>_INCLUDES  -I flags for this core
#   <name>_EXTS      ROM extensions for the registry (lowercase, no dot)
#
# Sources under a `libretro-common/` directory are pulled out of the per-core
# lists and compiled once, globally: several cores vendor the same files, and
# those symbols are not renamed per core, so duplicates would collide at link
# time. The pinned copy in third_party/libretro-common is used for all cores.

# Which cores end up in the binary. Override on the command line:
#
#   make CORES="smsplus gambatte fceumm"           # DS build
#
# This matters because every core is resident in RAM at once: the DS has 4 MiB
# and DSi mode 16 MiB (the linker enforces the budget and fails loudly with
# "region `ewram' overflowed"). Measured code+data+bss per core, ARMV5TE -O2:
#
#   fceumm        4.9 MiB     stella2014    1.1 MiB
#   beetle_pce_fast 3.2 MiB   beetle_vb     1.0 MiB
#   gambatte      2.1 MiB     smsplus       0.9 MiB
#   beetle_wswan  1.8 MiB     o2em          0.8 MiB
#   freeintv      1.7 MiB     prosystem     0.5 MiB
#                             handy         0.5 MiB
#                             beetle_ngp    0.4 MiB
#                             pokemini      0.2 MiB
#
# The default fits a DS (4 MiB) with room to spare. For DSi mode pick a larger
# set; see docs/TESTING.md.
CORES ?= testcore smsplus quicknes beetle_gba pokemini

LIBRETRO_COMMON_DIR := third_party/libretro-common

empty :=
space := $(empty) $(empty)
comma := ,

include $(addprefix cores/,$(addsuffix .mk,$(CORES)))

# Hand-written per-core tweaks live in cores/<name>.extra.mk so that re-running
# scripts/gen-core-mk.py never clobbers them.
-include $(addprefix cores/,$(addsuffix .extra.mk,$(CORES)))

# .../libretro-common/streams/memory_stream.c -> streams/memory_stream.c
# (make's patsubst only treats the first % as special, hence the subst/lastword)
LC_REL := $(sort $(foreach c,$(CORES),\
              $(foreach f,$($(c)_SRCS),\
                  $(if $(findstring libretro-common/,$(f)),\
                      $(lastword $(subst libretro-common/,$(space),$(f)))))))

# Baseline of libretro-common that the shared copy always builds, so that a
# core set which happens not to list (say) file_path.c still links.
LC_EXTRA := \
    string/rstrtod.c \
    string/stdstring.c \
    file/file_path.c \
    file/file_path_io.c \
    lists/string_list.c \
    encodings/encoding_utf.c \
    encodings/encoding_crc32.c \
    features/features_cpu.c \
    vfs/vfs_implementation.c \
    compat/compat_strl.c \
    compat/compat_strcasestr.c \
    compat/compat_snprintf.c \
    compat/compat_posix_string.c \
    compat/fopen_utf8.c \
    streams/file_stream.c \
    streams/file_stream_transforms.c \
    time/rtime.c

# features_cpu.c needs a timer; it takes the POSIX branch when this is defined
# (picolibc on the DS provides clock_gettime). See RD_LC_CFLAGS in core_rules.mk.
LC_EXCLUDE :=

LC_REL := $(filter-out $(LC_EXCLUDE),$(LC_REL))

LC_SRCS := $(addprefix $(LIBRETRO_COMMON_DIR)/,$(LC_REL) $(LC_EXTRA))

# The registry table is generated from the core list, so adding a core only
# means adding cores/<name>.mk and its name above.
GEN_DIR := $(BUILD)/gen

# Some cores need files their own build system generates as build inputs
# (config headers, lexers). Do it here, where every build passes, rather than
# only in the container-side scripts.
$(shell sh scripts/gen-core-inputs.sh >&2)

$(shell mkdir -p $(GEN_DIR))
$(shell sh scripts/gen-registry.sh $(GEN_DIR)/core_registry.inc \
            $(foreach c,$(CORES),$(c):$(subst $(space),$(comma),$($(c)_EXTS))))
