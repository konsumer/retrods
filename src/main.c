// SPDX-License-Identifier: Zlib
//
// retrods entry point. It is launched by Pico Launcher (via a file
// association) which passes the ROM path in argv[1]; argv[0] is the path of the
// retrods .nds itself. With no argument it prints the available cores.

#include "core.h"
#include "host.h"
#include "platform.h"

#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    const struct rd_core *core = NULL;
    const char *rom = NULL;
    const char *core_name = NULL;
    int rc;

    for (int i = 1; i < argc; i++) {
        if (strncmp(argv[i], "--core=", 7) == 0)
            core_name = argv[i] + 7;
        else if (!rom)
            rom = argv[i];
    }

    if (!rd_plat_init()) {
        rd_plat_hold("retrods: SD card init failed.\nLaunch this .nds through Pico Launcher\nso the DLDI driver is patched in.");
        rd_plat_deinit();
        return 1;
    }

    /* The firmware directory sits next to the .nds, so hand the platform the
       path we were launched from before any core asks for it. */
    rd_plat_set_program_path(argc > 0 ? argv[0] : NULL);

    if (core_name)
        core = rd_registry_find_by_name(core_name);
    if (!core && rom)
        core = rd_registry_find(rom);
    /* Single-core app (see scripts/build-apps.sh): with exactly one core
       registered it is the right one even if its extension list does not
       mention this particular file. */
    if (!core && rd_registry_at(0) && !rd_registry_at(1))
        core = rd_registry_at(0);

    if (!rom || !core) {
        char line[128];

        rd_plat_status("retrods");
        if (!rom)
            rd_plat_log("retrods: no ROM given");
        else
            snprintf(line, sizeof(line), "retrods: no core for %s", rom), rd_plat_log(line);
        rd_plat_log("usage: retrods <rom> [--core=<name>]");
        snprintf(line, sizeof(line), "firmware: %s", rd_plat_system_dir());
        rd_plat_log(line);
        rd_plat_log("available cores:");

        for (unsigned i = 0;; i++) {
            const struct rd_core *c = rd_registry_at(i);
            if (!c)
                break;
            snprintf(line, sizeof(line), "  %-10s (%s)", c->name, c->extensions[0]);
            rd_plat_log(line);
        }

        rd_plat_hold(NULL);
        rd_plat_deinit();
        return 2;
    }

    rc = rd_host_run(core, rom);

    rd_plat_deinit();
    return rc;
}
