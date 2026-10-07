# SPDX-License-Identifier: Zlib
#
# retrods — Nintendo DS(i) libretro frontend, argv-driven.
#
# Build inside the BlocksDS container:
#   ./scripts/build.sh            # DS build  -> retrods.nds
#   ./scripts/build.sh dsi        # DSi build -> retrods-dsi.nds
#
# Adding a core: create cores/<name>.mk and add <name> to CORES in common.mk.

export NM

export BLOCKSDS            ?= /opt/wonderful/thirdparty/blocksds/core
export NM

export BLOCKSDSEXT         ?= /opt/wonderful/thirdparty/blocksds/external
export WONDERFUL_TOOLCHAIN ?= /opt/wonderful
ARM_NONE_EABI_PATH         ?= $(WONDERFUL_TOOLCHAIN)/toolchain/gcc-arm-none-eabi/bin/

# Overridable so one app per core can be built (scripts/build-apps.sh).
NAME    ?= $(if $(filter 1,$(DSI)),retrods-dsi,retrods)
BUILD   ?= $(if $(filter 1,$(DSI)),build-dsi,build)
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
SPECS := $(BLOCKSDS)/sys/crts/ds_arm9.specs
NDSTOOL_ARGS :=
ifeq ($(DSI),1)
SPECS := $(BLOCKSDS)/sys/crts/dsi_arm9.specs
# 2 = runs on DS and DSi; the DSi memory map allows a larger ROM/heap.
NDSTOOL_ARGS += -uc 2
endif

# ARM7 companion binary. `minimal` is libnds only, which is all we need
# (keypad, touch, and the sound driver).
ARM7ELF ?= $(BLOCKSDS)/sys/arm7/main_core/arm7_minimal.elf

COMMONFLAGS := $(ARCH) -O2 -specs=$(SPECS) -DARM9 -D__NDS__ -D__BLOCKSDS__
RD_CFLAGS   := $(COMMONFLAGS)
RD_ASFLAGS  := $(ARCH) -specs=$(SPECS) -DARM9 -D__NDS__ -D__BLOCKSDS__
RD_CXXFLAGS := $(COMMONFLAGS) -fno-exceptions -fno-rtti -fno-threadsafe-statics

include common.mk

FE_CFLAGS := $(COMMONFLAGS) -Wall -Isrc -I$(BUILD)/gen -Isrc/cores \
             -I$(LIBRETRO_COMMON_DIR)/include -I$(BLOCKSDS)/libs/libnds/include

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
		-Wl,-Map,$(MAP)

$(ROM): $(ELF)
	@echo "  NDSTOOL $@"
	@$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-7 $(ARM7ELF) -9 $(ELF) \
		-g RETR 01 "$(GAME_TITLE)" $(NDSTOOL_ARGS)

size: $(ELF)
	$(PREFIX)size $(ELF)

dump: $(ELF)
	$(OBJDUMP) -h -C $(ELF) > $(BUILD)/$(NAME).dump

clean:
	@rm -rf build build-dsi retrods.nds retrods-dsi.nds

-include $(shell find $(BUILD) -name '*.d' 2>/dev/null)

$(BUILD)/fe/registry.o: $(GEN_DIR)/core_registry.inc
