# SPDX-License-Identifier: Zlib
#
# retrods — Nintendo DS(i) libretro frontend, argv-driven.
#
# Build inside the BlocksDS container:
#   ./scripts/build.sh            # -> retrods.nds
#
# Builds target DSi mode (dsi_arm9.specs: 16 MiB RAM, 133 MHz ARM9), which is
# the console this runs on.
#
# Adding a core: create cores/<name>.mk and add <name> to CORES in common.mk.

export NM

export BLOCKSDS            ?= /opt/wonderful/thirdparty/blocksds/core
export NM

export BLOCKSDSEXT         ?= /opt/wonderful/thirdparty/blocksds/external
export WONDERFUL_TOOLCHAIN ?= /opt/wonderful
ARM_NONE_EABI_PATH         ?= $(WONDERFUL_TOOLCHAIN)/toolchain/gcc-arm-none-eabi/bin/

# Overridable so one app per core can be built (scripts/build-apps.sh).
NAME    ?= retrods
BUILD   ?= build
GAME_TITLE ?= $(NAME)
ELF     := $(BUILD)/$(NAME).elf
ROM     := $(NAME).nds
MAP     := $(BUILD)/$(NAME).map

PREFIX  := $(ARM_NONE_EABI_PATH)arm-none-eabi-
CC      := $(PREFIX)gcc
CXX     := $(PREFIX)g++
OBJDUMP := $(PREFIX)objdump
NM      := $(PREFIX)nm
OBJCOPY := $(PREFIX)objcopy
LD_R    := $(PREFIX)ld

ARCH  := -mthumb -mcpu=arm946e-s+nofp
SPECS := $(BLOCKSDS)/sys/crts/dsi_arm9.specs
# 2 = runs on DS and DSi; the DSi memory map allows a larger ROM/heap.
NDSTOOL_ARGS := -uc 2
# EMU=1: a plain DS-mode build, for testing in melonDS without DSi BIOS dumps
# (scripts/emu-test.sh). Same code, DS memory map (4 MiB) and 67 MHz.
GAME_CODE := RETR
ifeq ($(EMU),1)
SPECS := $(BLOCKSDS)/sys/crts/ds_arm9.specs
NDSTOOL_ARGS :=
# melonDS only patches its DLDI driver (the virtual SD card) into ROMs it
# recognises as homebrew, and "####" is the game code it treats as homebrew.
GAME_CODE := \#\#\#\#
# ...and only when the stub reserves at least as much room as its driver
# declares, which is more than BlocksDS's default 16 KiB.
EMU_LDFLAGS := -Wl,--defsym=__dldi_size=32768
endif

# ARM7 companion binary. `minimal` is libnds only, which is all we need
# (keypad, touch, and the sound driver).
ARM7ELF ?= $(BLOCKSDS)/sys/arm7/main_core/arm7_minimal.elf

# Emulators are the one place where -O3 pays for itself; -O2 cost measurable
# frame rate on a 67 MHz ARM9. No -ffast-math: several cores need float
# exactness.
COMMONFLAGS := $(ARCH) -O3 -funroll-loops -fomit-frame-pointer -specs=$(SPECS) -DARM9 -D__NDS__ -D__BLOCKSDS__

# How the cores are compiled, separately from the frontend, so instruction set
# and optimisation level can be compared on hardware. Measured on a DSi with
# gambatte: ARM -O3 ran Tetris in 11-13 ms a frame, Thumb -O3 in 13-16 and
# Thumb -O2 in 15-17, so ARM -O3 is the default.
CORE_ISA ?= -marm
CORE_OPT ?= -O3 -funroll-loops
CORE_FLAGS := $(CORE_ISA) -mcpu=arm946e-s+nofp $(CORE_OPT) -fomit-frame-pointer \
              -specs=$(SPECS) -DARM9 -D__NDS__ -D__BLOCKSDS__
RD_CFLAGS   := $(CORE_FLAGS)
RD_ASFLAGS  := $(ARCH) -specs=$(SPECS) -DARM9 -D__NDS__ -D__BLOCKSDS__
RD_CXXFLAGS := $(CORE_FLAGS) -fno-exceptions -fno-rtti -fno-threadsafe-statics

include common.mk

# DS-only per-core settings, kept out of the host harness:
#   <core>_NDS_DROP           defines to remove from <core>_DEFINES
#   <core>_NDS_DEFINES        defines to add
#   <core>_NDS_NATIVE_PIXELS  1 if the core is patched to emit opaque BGR555,
#                             the DS's own format, so frames are DMA'd as is
$(foreach c,$(CORES),$(eval $(c)_DEFINES := $(filter-out $($(c)_NDS_DROP),$($(c)_DEFINES)) $($(c)_NDS_DEFINES)))
RD_NATIVE_PIXELS := $(if $(strip $(foreach c,$(CORES),$($(c)_NDS_NATIVE_PIXELS))),-DRD_NATIVE_PIXELS)

FE_CFLAGS := $(COMMONFLAGS) -Wall -Isrc -I$(BUILD)/gen -Isrc/cores \
             -I$(LIBRETRO_COMMON_DIR)/include -I$(BLOCKSDS)/libs/libnds/include \
             $(RD_NATIVE_PIXELS) -DRD_APP_NAME='"$(NAME)"'

NDS_FE_SRCS := src/main.c src/libretro_host.c src/registry.c src/nds/platform_nds.c
FE_OBJS := $(patsubst src/%.c,$(BUILD)/fe/%.o,$(NDS_FE_SRCS))

include core_rules.mk

# The selected core set can come from the command line, so a stamp of it is what
# tells make to relink when CORES changes.
CORES_STAMP := $(BUILD)/.cores

.PHONY: FORCE
FORCE:

$(CORES_STAMP): FORCE
	@mkdir -p $(@D)
	@printf '%s' "$(CORES)" | cmp -s - $@ || printf '%s' "$(CORES)" > $@

.DEFAULT_GOAL := all

.PHONY: all clean dump sdimage

.SECONDARY:

all: $(ROM)

$(BUILD)/fe/%.o: src/%.c
	@echo "  CC      $<"
	@mkdir -p $(@D)
	@$(CC) $(FE_CFLAGS) -MMD -MP -c -o $@ $<

$(ELF): $(FE_OBJS) $(RD_CORE_OBJS) $(RD_LC_OBJS) | $(CORES_STAMP)
	@echo "  LD      $@"
	@$(CC) -o $@ $^ $(ARCH) -specs=$(SPECS) \
		-L$(BLOCKSDS)/libs/libnds/lib \
		-Wl,--start-group -lnds9 -lstdc++ -lc -Wl,--end-group \
		-Wl,-Map,$(MAP) $(EMU_LDFLAGS)

$(ROM): $(ELF)
	@echo "  NDSTOOL $@"
	@$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-7 $(ARM7ELF) -9 $(ELF) \
		-g '$(GAME_CODE)' 01 "$(GAME_TITLE)" $(NDSTOOL_ARGS)

size: $(ELF)
	$(PREFIX)size $(ELF)

dump: $(ELF)
	$(OBJDUMP) -h -C $(ELF) > $(BUILD)/$(NAME).dump

clean:
	@rm -rf build build-apps retrods.nds

-include $(shell find $(BUILD) -name '*.d' 2>/dev/null)

$(BUILD)/fe/registry.o: $(GEN_DIR)/core_registry.inc
