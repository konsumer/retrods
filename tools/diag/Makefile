# SPDX-License-Identifier: Zlib
#
# Builds the diagnostic app with the same toolchain and flags as the emulator
# apps, so what it measures is what they experience.
#
#   scripts/build-diag.sh   (runs this inside the container)

export BLOCKSDS            ?= /opt/wonderful/thirdparty/blocksds/core
export WONDERFUL_TOOLCHAIN ?= /opt/wonderful
ARM_NONE_EABI_PATH         ?= $(WONDERFUL_TOOLCHAIN)/toolchain/gcc-arm-none-eabi/bin/

PREFIX  := $(ARM_NONE_EABI_PATH)arm-none-eabi-
CC      := $(PREFIX)gcc
ARCH    := -mthumb -mcpu=arm946e-s+nofp
SPECS   := $(BLOCKSDS)/sys/crts/ds_arm9.specs
ARM7ELF ?= $(BLOCKSDS)/sys/arm7/main_core/arm7_minimal.elf

CFLAGS  := $(ARCH) -O2 -specs=$(SPECS) -DARM9 -D__NDS__ -D__BLOCKSDS__ \
           -I$(BLOCKSDS)/libs/libnds/include -Wall
LDFLAGS := $(ARCH) -specs=$(SPECS) -L$(BLOCKSDS)/libs/libnds/lib \
           -Wl,--start-group -lnds9 -lc -Wl,--end-group

all: diag.nds

diag.o: diag.c
	$(CC) $(CFLAGS) -c -o $@ $<

diag.elf: diag.o
	$(CC) -o $@ $^ $(LDFLAGS) -Wl,-Map,diag.map

diag.nds: diag.elf
	$(BLOCKSDS)/tools/ndstool/ndstool -c $@ -7 $(ARM7ELF) -9 diag.elf -g RETR 01 "diag"

clean:
	rm -f diag.o diag.elf diag.map diag.nds

.PHONY: all clean
