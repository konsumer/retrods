# SPDX-License-Identifier: Zlib
#
# Generic per-core rules, shared by Makefile (DS) and Makefile.host (host test).
#
# Requires from the including makefile: BUILD, CC, CXX, LD_R, NM, OBJCOPY,
# RD_CFLAGS, RD_CXXFLAGS.
# Uses from common.mk: CORES, GEN_DIR, LIBRETRO_COMMON_DIR, LC_SRCS, <name>_*.
#
# Every core exports the same retro_* API, and cores also vendor and duplicate a
# lot of helper code (mednafen's Blip_Buffer, libretro-core-options tables, ...),
# so their symbols must be made unique before linking. Each core is therefore:
#
#   1. compiled plainly into its own object directory,
#   2. merged into a single relocatable object with `ld -r`,
#   3. rewritten with `objcopy --redefine-syms` so that every global symbol it
#      defines becomes <core>_<symbol>.
#
# Doing this at the object level (rather than with a generated -D header) is
# what makes C++ helpers work: mangled names never appear in the source, so the
# preprocessor can never see them.

RD_CORE_OBJS :=

define RD_CORE_RULES
$(1)_ALL_SRCS := $$($(1)_SRCS) $$($(1)_CXX_SRCS) $$($(1)_ASM_SRCS)
$(1)_CORE_SRCS := $$(foreach f,$$($(1)_ALL_SRCS),$$(if $$(findstring libretro-common/,$$(f)),,$$(f)))
$(1)_CORE_CXX_SRCS := $$(foreach f,$$($(1)_CXX_SRCS),$$(if $$(findstring libretro-common/,$$(f)),,$$(f)))
$(1)_CORE_ASM_SRCS := $$(foreach f,$$($(1)_ASM_SRCS),$$(if $$(findstring libretro-common/,$$(f)),,$$(f)))
$(1)_OBJS := $$(sort \
    $$(patsubst $$($(1)_DIR)/%.c,$$(BUILD)/core/$(1)/%.o,$$(filter %.c,$$($(1)_CORE_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.cpp,$$(BUILD)/core/$(1)/%.opp,$$(filter %.cpp,$$($(1)_CORE_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.cc,$$(BUILD)/core/$(1)/%.opp,$$(filter %.cc,$$($(1)_CORE_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.cxx,$$(BUILD)/core/$(1)/%.opp,$$(filter %.cxx,$$($(1)_CORE_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.c,$$(BUILD)/core/$(1)/%.opp,$$(filter %.c,$$($(1)_CORE_CXX_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.cpp,$$(BUILD)/core/$(1)/%.opp,$$(filter %.cpp,$$($(1)_CORE_CXX_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.cc,$$(BUILD)/core/$(1)/%.opp,$$(filter %.cc,$$($(1)_CORE_CXX_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.cxx,$$(BUILD)/core/$(1)/%.opp,$$(filter %.cxx,$$($(1)_CORE_CXX_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.S,$$(BUILD)/core/$(1)/%.oS,$$(filter %.S,$$($(1)_CORE_ASM_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.s,$$(BUILD)/core/$(1)/%.oS,$$(filter %.s,$$($(1)_CORE_ASM_SRCS))) \
    $$(patsubst $$($(1)_DIR)/%.asm,$$(BUILD)/core/$(1)/%.oS,$$(filter %.asm,$$($(1)_CORE_ASM_SRCS))))
$(1)_BUNDLE := $$(BUILD)/bundle/$(1).o
$(1)_RENAME := $$(BUILD)/gen/rename_$(1).txt
# Editing how a core is built must force a relink: make only compares
# timestamps, so a changed prerequisite *set* would otherwise go unnoticed.
$(1)_MKDEPS := cores/$(1).mk $$(wildcard cores/$(1).extra.mk) common.mk core_rules.mk

RD_CORE_OBJS += $$($(1)_BUNDLE)

$$(BUILD)/core/$(1)/%.o: $$($(1)_DIR)/%.c
	@mkdir -p $$(@D)
	$$(CC) $$(RD_CFLAGS) $$($(1)_CFLAGS) $$($(1)_DEFINES) -I$$(LIBRETRO_COMMON_DIR)/include \
	    $$($(1)_INCLUDES) -c -o $$@ $$<

$$(BUILD)/core/$(1)/%.opp: $$($(1)_DIR)/%.cpp
	@mkdir -p $$(@D)
	$$(CXX) $$(RD_CXXFLAGS) $$($(1)_CXXFLAGS) $$($(1)_DEFINES) -I$$(LIBRETRO_COMMON_DIR)/include \
	    $$($(1)_INCLUDES) -c -o $$@ $$<

$$(BUILD)/core/$(1)/%.opp: $$($(1)_DIR)/%.cc
	@mkdir -p $$(@D)
	$$(CXX) $$(RD_CXXFLAGS) $$($(1)_CXXFLAGS) $$($(1)_DEFINES) -I$$(LIBRETRO_COMMON_DIR)/include \
	    $$($(1)_INCLUDES) -c -o $$@ $$<

$$(BUILD)/core/$(1)/%.opp: $$($(1)_DIR)/%.cxx
	@mkdir -p $$(@D)
	$$(CXX) $$(RD_CXXFLAGS) $$($(1)_CXXFLAGS) $$($(1)_DEFINES) -I$$(LIBRETRO_COMMON_DIR)/include \
	    $$($(1)_INCLUDES) -c -o $$@ $$<

$$(BUILD)/core/$(1)/%.opp: $$($(1)_DIR)/%.c
	@mkdir -p $$(@D)
	$$(CXX) $$(RD_CXXFLAGS) $$($(1)_CXXFLAGS) $$($(1)_DEFINES) -I$$(LIBRETRO_COMMON_DIR)/include \
	    $$($(1)_INCLUDES) -x c++ -c -o $$@ $$<

$$(BUILD)/core/$(1)/%.oS: $$($(1)_DIR)/%.S
	@mkdir -p $$(@D)
	$$(CC) $$(RD_ASFLAGS) $$($(1)_DEFINES) -I$$(LIBRETRO_COMMON_DIR)/include \
	    $$($(1)_INCLUDES) -x assembler-with-cpp -c -o $$@ $$<

$$(BUILD)/core/$(1)/%.oS: $$($(1)_DIR)/%.s
	@mkdir -p $$(@D)
	$$(CC) $$(RD_ASFLAGS) $$($(1)_DEFINES) -I$$(LIBRETRO_COMMON_DIR)/include \
	    $$($(1)_INCLUDES) -x assembler-with-cpp -c -o $$@ $$<

$$($(1)_BUNDLE): $$($(1)_OBJS) $$($(1)_MKDEPS)
	@echo "  BUNDLE  $$@"
	@mkdir -p $$(@D)
	$$(LD_R) -r -o $$@ $$($(1)_OBJS)
	$$(NM) -g --defined-only --format=posix $$@ | cut -d' ' -f1 | grep -v '^$$$$' \
	    | while read -r s; do echo "$$$$s $(1)_$$$$s"; done > $$($(1)_RENAME)
	$$(OBJCOPY) --redefine-syms=$$($(1)_RENAME) $$@
endef

# libretro-common is compiled once and linked into every build. It is not
# renamed, because all cores must agree on a single copy of it.
RD_LC_CFLAGS ?= -D_POSIX_MONOTONIC_CLOCK

RD_LC_OBJS := $(patsubst $(LIBRETRO_COMMON_DIR)/%.c,$(BUILD)/lc/%.o,$(LC_SRCS))

$(BUILD)/lc/%.o: $(LIBRETRO_COMMON_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(RD_CFLAGS) $(RD_LC_CFLAGS) -I$(LIBRETRO_COMMON_DIR)/include -c -o $@ $<

$(foreach c,$(CORES),$(eval $(call RD_CORE_RULES,$(c))))
