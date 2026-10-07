// SPDX-License-Identifier: Zlib
//
// Registry of libretro cores statically linked into retrods.
//
// Every core exports the same `retro_*` symbols, so each one is compiled with a
// generated header (scripts/gen-prefix.sh) that renames the libretro API to
// `<core>_retro_*`. The table itself is generated from `CORES` in common.mk
// into build/gen/core_registry.inc.

#include "core.h"

#include <string.h>

// F(core, name, return_type, arguments)
#define RD_API_LIST(F, c)                                       \
    F(c, init, void, (void))                                    \
    F(c, deinit, void, (void))                                  \
    F(c, api_version, unsigned, (void))                         \
    F(c, get_system_info, void, (struct retro_system_info *))   \
    F(c, get_system_av_info, void, (struct retro_system_av_info *)) \
    F(c, set_controller_port_device, void, (unsigned, unsigned)) \
    F(c, reset, void, (void))                                   \
    F(c, run, void, (void))                                     \
    F(c, serialize_size, size_t, (void))                        \
    F(c, serialize, bool, (void *, size_t))                     \
    F(c, unserialize, bool, (const void *, size_t))             \
    F(c, cheat_reset, void, (void))                             \
    F(c, cheat_set, void, (unsigned, bool, const char *))       \
    F(c, load_game, bool, (const struct retro_game_info *))     \
    F(c, load_game_special, bool, (unsigned, const struct retro_game_info *, size_t)) \
    F(c, unload_game, void, (void))                             \
    F(c, get_region, unsigned, (void))                          \
    F(c, get_memory_data, void *, (unsigned))                   \
    F(c, get_memory_size, size_t, (unsigned))                   \
    F(c, set_environment, void, (retro_environment_t))          \
    F(c, set_video_refresh, void, (retro_video_refresh_t))      \
    F(c, set_audio_sample, void, (retro_audio_sample_t))        \
    F(c, set_audio_sample_batch, void, (retro_audio_sample_batch_t)) \
    F(c, set_input_poll, void, (retro_input_poll_t))            \
    F(c, set_input_state, void, (retro_input_state_t))

#define RD_DECL(c, fn, ret, args) extern ret c##_retro_##fn args;
#define RD_BIND(c, fn, ret, args) .fn = c##_retro_##fn,

// Generated entries: RD_ENTRY(name, "ext", "ext", ...)
#define RD_ENTRY RD_ENTRY_DECLS
#define RD_ENTRY_DECLS(n, ...)                       \
    RD_API_LIST(RD_DECL, n)                          \
    static const char *const n##_exts[] = { __VA_ARGS__, NULL };
#include "core_registry.inc"
#undef RD_ENTRY_DECLS
#undef RD_ENTRY

#define RD_ENTRY RD_ENTRY_STRUCTS
#define RD_ENTRY_STRUCTS(n, ...)                     \
    {                                                \
        .name = #n,                                  \
        .extensions = n##_exts,                      \
        RD_API_LIST(RD_BIND, n)                      \
    },
static const struct rd_core g_cores[] = {
#include "core_registry.inc"
};
#undef RD_ENTRY_STRUCTS
#undef RD_ENTRY

#define RD_CORE_COUNT (sizeof(g_cores) / sizeof(g_cores[0]))

static const char *extension_of(const char *path)
{
    const char *dot = strrchr(path, '.');
    if (!dot || !dot[1])
        return NULL;
    return dot + 1;
}

static int ext_matches(const char *ext, const char *candidate)
{
    for (; *ext && *candidate; ext++, candidate++) {
        char a = *ext, b = *candidate;
        if (a >= 'A' && a <= 'Z')
            a += 'a' - 'A';
        if (b >= 'A' && b <= 'Z')
            b += 'a' - 'A';
        if (a != b)
            return 0;
    }
    return *ext == '\0' && *candidate == '\0';
}

const struct rd_core *rd_registry_find(const char *rom_path)
{
    const char *ext = extension_of(rom_path);
    if (!ext)
        return NULL;

    for (unsigned i = 0; i < RD_CORE_COUNT; i++) {
        const struct rd_core *c = &g_cores[i];
        for (unsigned j = 0; c->extensions[j]; j++) {
            if (ext_matches(ext, c->extensions[j]))
                return c;
        }
    }
    return NULL;
}

const struct rd_core *rd_registry_find_by_name(const char *name)
{
    for (unsigned i = 0; i < RD_CORE_COUNT; i++) {
        if (strcmp(g_cores[i].name, name) == 0)
            return &g_cores[i];
    }
    return NULL;
}

const struct rd_core *rd_registry_at(unsigned index)
{
    if (index >= RD_CORE_COUNT)
        return NULL;
    return &g_cores[index];
}
