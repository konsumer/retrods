// SPDX-License-Identifier: Zlib
//
// Generic libretro frontend glue: environment callback, video/audio/input
// callbacks, the run loop and SRAM persistence. Shared by every platform.

#include "host.h"
#include "platform.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const struct rd_core *g_core;
static const char *g_rom_path;
static enum rd_pixel_format g_pixfmt = RD_PIXEL_0RGB1555;
static unsigned g_sample_rate = 44100;
static unsigned g_frames;             /* frames handed to the platform */
static bool g_shutdown;



/* Core options.
 *
 * Cores register their options and then read them back with
 * RETRO_ENVIRONMENT_GET_VARIABLE. A frontend that cannot answer makes some
 * cores take a disabled code path: VICE zeroes its resources (no audio), and
 * libretro-cap32 never calls video_setup(), leaving retro_video.rgb2color NULL
 * for its UI to call through.
 *
 * The tables must be *copied* when they are handed over: quicknes, for one,
 * passes an array that lives on its stack, so a pointer kept for later use
 * points at reused memory.
 *
 * Only the long-stable interfaces are honoured - SET_VARIABLES (16) and
 * SET_CORE_OPTIONS/INTL (53/54). The V2 tables are not parsed, because a core
 * built against an older libretro.h can hand over a payload whose layout does
 * not match our structs.
 */
#define RD_MAX_OPTIONS    96
#define RD_OPTION_STRLEN 160

static char g_opt_key[RD_MAX_OPTIONS][RD_OPTION_STRLEN];
static char g_opt_value[RD_MAX_OPTIONS][RD_OPTION_STRLEN];
static unsigned g_opt_count;

/* A legacy variable's value is "Description; default|other|..."; the default is
 * the first entry. A table-driven option already carries one value per entry. */
static void copy_default(char *dst, size_t n, const char *value)
{
    const char *p = value;
    size_t i = 0;

    if (!value) {
        dst[0] = '\0';
        return;
    }

    {
        const char *sep = strchr(p, ';');
        if (sep) {
            p = sep + 1;
            while (*p == ' ')
                p++;
        }
    }

    while (p[i] && p[i] != '|' && i + 1 < n) {
        dst[i] = p[i];
        i++;
    }
    dst[i] = '\0';
}

static void option_add(const char *key, const char *value)
{
    size_t i = 0;

    if (g_opt_count >= RD_MAX_OPTIONS || !key || !value)
        return;

    while (key[i] && i + 1 < RD_OPTION_STRLEN) {
        g_opt_key[g_opt_count][i] = key[i];
        i++;
    }
    g_opt_key[g_opt_count][i] = '\0';

    copy_default(g_opt_value[g_opt_count], RD_OPTION_STRLEN, value);
    g_opt_count++;
}

static const char *option_default(const char *key)
{
    unsigned i;

    if (!key)
        return NULL;

    for (i = 0; i < g_opt_count; i++)
        if (!strcmp(g_opt_key[i], key))
            return g_opt_value[i];

    return NULL;
}

static void logf_(const char *fmt, ...)
{
    char buf[256];
    va_list ap;

    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);

    rd_plat_log(buf);
}

static void log_printf_cb(enum retro_log_level level, const char *fmt, ...)
{
    char buf[256];
    va_list ap;

    (void)level;

    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);

    rd_plat_log(buf);
}

static bool env_cb(unsigned cmd, void *data)
{
    switch (cmd) {
    case RETRO_ENVIRONMENT_SET_PIXEL_FORMAT: {
        const enum retro_pixel_format *f = (const enum retro_pixel_format *)data;
        if (*f == RETRO_PIXEL_FORMAT_0RGB1555 ||
            *f == RETRO_PIXEL_FORMAT_RGB565 ||
            *f == RETRO_PIXEL_FORMAT_XRGB8888) {
            g_pixfmt = (enum rd_pixel_format)*f;
            return true;
        }
        return false;
    }

    case RETRO_ENVIRONMENT_GET_LOG_INTERFACE: {
        struct retro_log_callback *cb = (struct retro_log_callback *)data;
        cb->log = log_printf_cb;
        return true;
    }

    case RETRO_ENVIRONMENT_GET_SYSTEM_DIRECTORY:
        *(const char **)data = rd_plat_system_dir();
        return true;

    case RETRO_ENVIRONMENT_GET_SAVE_DIRECTORY:
        *(const char **)data = rd_plat_save_dir();
        return true;

    case RETRO_ENVIRONMENT_GET_CAN_DUPE:
        *(bool *)data = true;
        return true;

    case RETRO_ENVIRONMENT_GET_INPUT_BITMASKS:
        return true;

    case RETRO_ENVIRONMENT_GET_AUDIO_VIDEO_ENABLE:
        /* Bit 0 = video, bit 1 = audio. Cores that ask this will otherwise
           assume the frontend cannot tell them and may skip output. */
        if (!data)
            return false;
        *(int *)data = 1 | 2;
        return true;

    case RETRO_ENVIRONMENT_GET_LANGUAGE:
        *(unsigned *)data = RETRO_LANGUAGE_ENGLISH;
        return true;

    case RETRO_ENVIRONMENT_GET_VARIABLE_UPDATE:
        *(bool *)data = false;
        return true;

    case RETRO_ENVIRONMENT_GET_VARIABLE: {
        struct retro_variable *var = (struct retro_variable *)data;
        const char *value;
        value = (var && var->key) ? option_default(var->key) : NULL;
        if (!value)
            return false;
        var->value = value;
        return true;
    }

    case RETRO_ENVIRONMENT_SET_VARIABLES: {
        const struct retro_variable *v = (const struct retro_variable *)data;
        g_opt_count = 0;
        for (; v && v->key && g_opt_count < RD_MAX_OPTIONS; v++)
            option_add(v->key, v->value);
        return true;
    }

    case RETRO_ENVIRONMENT_SET_CORE_OPTIONS: {
        const struct retro_core_option_definition *d =
            (const struct retro_core_option_definition *)data;
        g_opt_count = 0;
        for (; d && d->key && g_opt_count < RD_MAX_OPTIONS; d++)
            option_add(d->key, d->values[0].value);
        return true;
    }

    case RETRO_ENVIRONMENT_SET_CORE_OPTIONS_INTL: {
        const struct retro_core_options_intl *intl =
            (const struct retro_core_options_intl *)data;
        const struct retro_core_option_definition *d = intl ? intl->us : NULL;
        g_opt_count = 0;
        for (; d && d->key && g_opt_count < RD_MAX_OPTIONS; d++)
            option_add(d->key, d->values[0].value);
        return true;
    }

    case RETRO_ENVIRONMENT_SHUTDOWN:
        g_shutdown = true;
        return true;

    // Accepted / ignored: the frontend is headless on these axes.
    case RETRO_ENVIRONMENT_SET_INPUT_DESCRIPTORS:
    case RETRO_ENVIRONMENT_SET_CORE_OPTIONS_V2:
    case RETRO_ENVIRONMENT_SET_CORE_OPTIONS_V2_INTL:
    case RETRO_ENVIRONMENT_SET_CORE_OPTIONS_DISPLAY:
    case RETRO_ENVIRONMENT_SET_CORE_OPTIONS_UPDATE_DISPLAY_CALLBACK:
    case RETRO_ENVIRONMENT_SET_MEMORY_MAPS:
    case RETRO_ENVIRONMENT_SET_CONTROLLER_INFO:
    case RETRO_ENVIRONMENT_SET_PERFORMANCE_LEVEL:
    case RETRO_ENVIRONMENT_SET_SUPPORT_ACHIEVEMENTS:
    case RETRO_ENVIRONMENT_SET_SYSTEM_AV_INFO:
    case RETRO_ENVIRONMENT_SET_GEOMETRY:
        return true;

    default:
        return false;
    }
}

// The last frame the core handed over, so a screenshot can be taken from the
// hotkey rather than from inside the video callback.
static const void *s_frame_data;
static unsigned s_frame_w, s_frame_h;
static size_t s_frame_pitch;

static void video_cb(const void *data, unsigned width, unsigned height, size_t pitch)
{
    if (data)
        g_frames++;

    s_frame_data = data;
    s_frame_w = width;
    s_frame_h = height;
    s_frame_pitch = pitch;

    rd_plat_video(data, width, height, pitch, g_pixfmt);
}

static void screenshot_save(const char *rom_path)
{
    char base[512];

    if (!s_frame_data) {
        logf_("screenshot: no frame yet");
        return;
    }

    snprintf(base, sizeof(base), "%s_%08u", rom_path, g_frames);
    rd_plat_screenshot(s_frame_data, s_frame_w, s_frame_h, s_frame_pitch,
                       g_pixfmt, base);
}

static void audio_cb(int16_t left, int16_t right)
{
    int16_t frame[2] = { left, right };
    rd_plat_audio(frame, 1, g_sample_rate);
}

static size_t audio_batch_cb(const int16_t *data, size_t frames)
{
    rd_plat_audio(data, frames, g_sample_rate);
    return frames;
}

static void input_poll_cb(void)
{
    rd_plat_poll_input();
}

static int16_t input_state_cb(unsigned port, unsigned device, unsigned index, unsigned id)
{
    if (port != 0 || index != 0 || device != RETRO_DEVICE_JOYPAD)
        return 0;

    if (id == RETRO_DEVICE_ID_JOYPAD_MASK) {
        uint16_t mask = 0;
        for (unsigned i = 0; i <= RETRO_DEVICE_ID_JOYPAD_R3; i++) {
            if (rd_plat_button(i))
                mask |= (uint16_t)(1u << i);
        }
        return (int16_t)mask;
    }

    return rd_plat_button(id) ? 1 : 0;
}

static void sram_path(const char *rom_path, char *out, size_t out_size)
{
    snprintf(out, out_size, "%s.srm", rom_path);
}

static void load_sram(void)
{
    size_t size = g_core->get_memory_size(RETRO_MEMORY_SAVE_RAM);
    void *mem = g_core->get_memory_data(RETRO_MEMORY_SAVE_RAM);
    char path[512];
    void *file;
    size_t file_size = 0;

    if (!mem || !size)
        return;

    sram_path(g_rom_path, path, sizeof(path));

    file = rd_plat_read_file(path, &file_size);
    if (!file)
        return;

    memcpy(mem, file, file_size < size ? file_size : size);
    free(file);
    logf_("SRAM: loaded %u bytes", (unsigned)(file_size < size ? file_size : size));
}

static void save_sram(void)
{
    size_t size = g_core->get_memory_size(RETRO_MEMORY_SAVE_RAM);
    void *mem = g_core->get_memory_data(RETRO_MEMORY_SAVE_RAM);
    char path[512];

    if (!mem || !size)
        return;

    sram_path(g_rom_path, path, sizeof(path));

    if (rd_plat_write_file(path, mem, size))
        logf_("SRAM: saved %u bytes", (unsigned)size);
    else
        logf_("SRAM: could not write %s", path);
}

// Save states. One slot per game, kept next to it as <rom>.state, the same way
// SRAM is kept as <rom>.srm.
static void state_path(char *out, size_t out_size, const char *rom_path)
{
    snprintf(out, out_size, "%s.state", rom_path);
}

static void state_save(const struct rd_core *core, const char *rom_path)
{
    char path[512];
    size_t size;
    void *buf;

    state_path(path, sizeof(path), rom_path);

    size = core->serialize_size ? core->serialize_size() : 0;
    if (!size) {
        logf_("state: this core cannot save states");
        return;
    }

    buf = malloc(size);
    if (!buf) {
        logf_("state: out of memory (%u bytes)", (unsigned)size);
        return;
    }

    if (core->serialize && core->serialize(buf, size) &&
        rd_plat_write_file(path, buf, size))
        logf_("state: saved %u bytes to %s", (unsigned)size, path);
    else
        logf_("state: could not write %s", path);

    free(buf);
}

static void state_load(const struct rd_core *core, const char *rom_path)
{
    char path[512];
    size_t size = 0;
    void *buf;

    state_path(path, sizeof(path), rom_path);

    if (!core->unserialize) {
        logf_("state: this core cannot load states");
        return;
    }

    buf = rd_plat_read_file(path, &size);
    if (!buf) {
        logf_("state: no state at %s", path);
        return;
    }

    if (core->unserialize(buf, size))
        logf_("state: loaded %u bytes from %s", (unsigned)size, path);
    else
        logf_("state: %s is not a state this core accepts", path);

    free(buf);
}

// Hotkeys, all held with L+R so a game cannot trigger one by accident:
//
//     L+R+START         save state
//     L+R+SELECT        load state
//     L+R+X             screenshot      (written as <rom>_NNNN.ppm/.bmp)
//     L+R+A             fast-forward    (while held)
//     L+R+START+SELECT  quit            (handled by the platform)
//
// Edges are detected here, so leaning on a combo performs one action, not one
// per frame.
static bool s_hk_prev[3];

static void handle_hotkeys(const struct rd_core *core, const char *rom_path)
{
    bool mod = rd_plat_button(RETRO_DEVICE_ID_JOYPAD_L) &&
               rd_plat_button(RETRO_DEVICE_ID_JOYPAD_R);
    bool now[3];

    now[0] = mod && rd_plat_button(RETRO_DEVICE_ID_JOYPAD_START);
    now[1] = mod && rd_plat_button(RETRO_DEVICE_ID_JOYPAD_SELECT);
    now[2] = mod && rd_plat_button(RETRO_DEVICE_ID_JOYPAD_X);

    if (now[0] && !s_hk_prev[0])
        state_save(core, rom_path);
    if (now[1] && !s_hk_prev[1])
        state_load(core, rom_path);
    if (now[2] && !s_hk_prev[2])
        screenshot_save(rom_path);

    memcpy(s_hk_prev, now, sizeof(now));
}

static bool fast_forward_held(void)
{
    return rd_plat_button(RETRO_DEVICE_ID_JOYPAD_L) &&
           rd_plat_button(RETRO_DEVICE_ID_JOYPAD_R) &&
           rd_plat_button(RETRO_DEVICE_ID_JOYPAD_A);
}

int rd_host_run(const struct rd_core *core, const char *rom_path)
{
    struct retro_system_info sys_info;
    struct retro_system_av_info av_info;
    struct retro_game_info game_info;
    void *rom;
    size_t rom_size = 0;

    rom = rd_plat_read_file(rom_path, &rom_size);
    if (!rom) {
        logf_("cannot read ROM: %s", rom_path);
        return 1;
    }

    g_core = core;
    g_rom_path = rom_path;
    g_shutdown = false;

    core->set_environment(env_cb);
    core->set_video_refresh(video_cb);
    core->set_audio_sample(audio_cb);
    core->set_audio_sample_batch(audio_batch_cb);
    core->set_input_poll(input_poll_cb);
    core->set_input_state(input_state_cb);

    core->init();

    memset(&sys_info, 0, sizeof(sys_info));
    core->get_system_info(&sys_info);
    logf_("core: %s (%s %s)", core->name,
          sys_info.library_name ? sys_info.library_name : core->name,
          sys_info.library_version ? sys_info.library_version : "");
    rd_plat_status(sys_info.library_name ? sys_info.library_name : core->name);

    memset(&game_info, 0, sizeof(game_info));
    game_info.path = rom_path;
    game_info.data = rom;
    game_info.size = rom_size;
    game_info.meta = NULL;

    if (!core->load_game(&game_info)) {
        logf_("core rejected content: %s", rom_path);
        core->deinit();
        free(rom);
        return 2;
    }

    memset(&av_info, 0, sizeof(av_info));
    core->get_system_av_info(&av_info);
    if (av_info.timing.sample_rate > 0)
        g_sample_rate = (unsigned)av_info.timing.sample_rate;
    logf_("video %ux%u @ %.2f fps, audio %u Hz",
          av_info.geometry.base_width, av_info.geometry.base_height,
          av_info.timing.fps, g_sample_rate);

    load_sram();

    while (!g_shutdown && !rd_plat_quit_requested()) {
        core->run();
        /* The core polls input once per frame; read the hotkeys from that same
           state, so a press cannot fall between two polls. */
        handle_hotkeys(core, rom_path);
        /* Fast-forward by not waiting for the frame boundary. */
        if (!fast_forward_held())
            rd_plat_wait_frame();
    }

    save_sram();

    core->unload_game();
    core->deinit();
    free(rom);

    return 0;
}
