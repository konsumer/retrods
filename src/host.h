// SPDX-License-Identifier: Zlib

#ifndef RETRODS_HOST_H
#define RETRODS_HOST_H

#include "core.h"

// Load `rom_path` with `core`, run it until the user quits, then persist SRAM
// next to the ROM and shut the core down. Returns 0 on success.
int rd_host_run(const struct rd_core *core, const char *rom_path);

// Bench mode (see main.c): stop after this many frames (0 = run until quit),
// and leave the game's save file alone.
extern unsigned rd_host_max_frames;
extern bool rd_host_no_save;

#endif // RETRODS_HOST_H
