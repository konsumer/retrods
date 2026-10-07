// SPDX-License-Identifier: Zlib
//
// Description of one statically linked libretro core, plus the registry that
// maps file extensions / names to cores.

#ifndef RETRODS_CORE_H
#define RETRODS_CORE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "libretro.h"

struct rd_core {
    const char *name;
    // NULL-terminated list of lowercase extensions without the dot.
    const char *const *extensions;

    void (*init)(void);
    void (*deinit)(void);
    unsigned (*api_version)(void);
    void (*get_system_info)(struct retro_system_info *);
    void (*get_system_av_info)(struct retro_system_av_info *);
    void (*set_controller_port_device)(unsigned, unsigned);
    void (*reset)(void);
    void (*run)(void);
    size_t (*serialize_size)(void);
    bool (*serialize)(void *, size_t);
    bool (*unserialize)(const void *, size_t);
    void (*cheat_reset)(void);
    void (*cheat_set)(unsigned, bool, const char *);
    bool (*load_game)(const struct retro_game_info *);
    bool (*load_game_special)(unsigned, const struct retro_game_info *, size_t);
    void (*unload_game)(void);
    unsigned (*get_region)(void);
    void *(*get_memory_data)(unsigned);
    size_t (*get_memory_size)(unsigned);

    void (*set_environment)(retro_environment_t);
    void (*set_video_refresh)(retro_video_refresh_t);
    void (*set_audio_sample)(retro_audio_sample_t);
    void (*set_audio_sample_batch)(retro_audio_sample_batch_t);
    void (*set_input_poll)(retro_input_poll_t);
    void (*set_input_state)(retro_input_state_t);
};

// Pick a core from a ROM path (by extension).
const struct rd_core *rd_registry_find(const char *rom_path);

// Pick a core by its short name (e.g. "smsplus").
const struct rd_core *rd_registry_find_by_name(const char *name);

// For diagnostics / listing.
const struct rd_core *rd_registry_at(unsigned index);

#endif // RETRODS_CORE_H
