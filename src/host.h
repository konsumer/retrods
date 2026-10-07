// SPDX-License-Identifier: Zlib

#ifndef RETRODS_HOST_H
#define RETRODS_HOST_H

#include "core.h"

// Load `rom_path` with `core`, run it until the user quits, then persist SRAM
// next to the ROM and shut the core down. Returns 0 on success.
int rd_host_run(const struct rd_core *core, const char *rom_path);

#endif // RETRODS_HOST_H
