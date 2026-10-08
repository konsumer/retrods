// SPDX-License-Identifier: Zlib
//
// retrods entry point. It is launched by Pico Launcher (via a file
// association) which passes the ROM path in argv[1]; argv[0] is the path of the
// retrods .nds itself. With no argument it prints the available cores.

#include "core.h"
#include "host.h"
#include "platform.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Bench mode: launched with no ROM (straight from Pico Launcher's app list), a
// single-core app looks for bench.txt next to itself. Each line is a ROM path;
// each ROM runs for BENCH_FRAMES with no input and its saves left alone, and
// the per-second stats go to retrods.log in the same directory.
#define BENCH_FRAMES (20 * 60)

// "<dir of argv0>/<name>", or just <name> when argv0 has no directory.
static void app_file(char *out, size_t n, const char *argv0, const char *name)
{
    const char *slash = argv0 ? strrchr(argv0, '/') : NULL;

    if (slash)
        snprintf(out, n, "%.*s/%s", (int)(slash - argv0), argv0, name);
    else
        snprintf(out, n, "%s", name);
}

static int run_bench(const struct rd_core *core, const char *list, const char *log)
{
    size_t size = 0;
    char *text = rd_plat_read_file(list, &size);
    char *line, *next;
    int ran = 0;

    if (!text)
        return -1;

    text = realloc(text, size + 1);
    text[size] = '\0';

    rd_host_max_frames = BENCH_FRAMES;
    rd_host_no_save = true;

    for (line = text; line && *line; line = next) {
        next = strpbrk(line, "\r\n");
        if (next) {
            *next++ = '\0';
            next += strspn(next, "\r\n");
        }
        if (!*line || *line == '#')
            continue;

        rd_plat_stats_begin(line);
        rd_host_run(core, line);
        rd_plat_stats_flush(log);
        ran++;

        if (rd_plat_quit_requested())
            break;
    }

    free(text);
    return ran;
}

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

    if (!rom && core) {
        char list[256], log[256];

        app_file(list, sizeof(list), argc > 0 ? argv[0] : NULL, "bench.txt");
        app_file(log, sizeof(log), argc > 0 ? argv[0] : NULL, "retrods.log");
        if (rd_plat_file_exists(list)) {
            rd_plat_log("bench mode");
            rc = run_bench(core, list, log);
            rd_plat_log("bench done");
            rd_plat_deinit();
            return rc > 0 ? 0 : 1;
        }
    }

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

    {
        char log[256];

        app_file(log, sizeof(log), argc > 0 ? argv[0] : NULL, "retrods.log");
        rd_plat_stats_begin(rom);
        rc = rd_host_run(core, rom);
        rd_plat_stats_flush(log);
    }

    rd_plat_deinit();
    return rc;
}
