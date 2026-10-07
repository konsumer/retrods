# C64 core.
#
#  * -fexceptions: a few C++ units throw.
#  * -Wno-implicit-function-declaration: strcasestr is a GNU extension that
#    libretro-common's compat_strcasestr.c provides without a declaration.
#  * CORE_NAME: the core's own Makefile supplies the machine name this way.
#
# patches/vice-libretro/ turns off reSID in include/config.h, which leaves
# FASTSID as the SID engine. The reSID and reSID-FP sources are then dropped from
# the build: they are unreferenced, and reSID's 6581 filter tables alone are
# 21 MiB of .bss (opamp_rev[1<<16], gain[16][1<<16], summer/mixer offsets),
# which is more than a DS or a DSi has.
vice_x64_DEFINES += -DCORE_NAME=\"x64\"
vice_x64_CXXFLAGS := -fexceptions -Wno-incompatible-pointer-types
vice_x64_CFLAGS := -Wno-implicit-function-declaration -Wno-incompatible-pointer-types

# /resid matches both vice/src/resid*/ and the vice/src/sid/resid* glue.
vice_x64_drop_resid = $(if $(findstring /resid,$(1)),,$(1))
vice_x64_SRCS := $(foreach f,$(vice_x64_SRCS),$(call vice_x64_drop_resid,$(f)))
vice_x64_CXX_SRCS := $(foreach f,$(vice_x64_CXX_SRCS),$(call vice_x64_drop_resid,$(f)))

vice_x64_EXTS := crt d64 t64 p00 prg tap

# retrods: add t64/p00: Commodore tape and PC64 images, where they belong.
