// SPDX-License-Identifier: Zlib
//
// A tiny self-contained libretro core used to validate the frontend and the
// DS video/audio/input path without needing any copyrighted ROM. It ignores
// the loaded content and renders an animated pattern while emitting a tone.

#include <libretro.h>

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define TC_W 256
#define TC_H 192
#define TC_RATE 44100
#define TC_FPS  60

static uint16_t s_fb[TC_W * TC_H];
static int16_t s_snd[2 * (TC_RATE / TC_FPS + 1)];
static unsigned s_frame;
static bool s_loaded;

static retro_environment_t s_env;
static retro_video_refresh_t s_video;
static retro_audio_sample_batch_t s_audio_batch;
static retro_input_poll_t s_input_poll;
static retro_input_state_t s_input_state;

static void render(void)
{
    unsigned bar = s_frame % TC_W;

    for (unsigned y = 0; y < TC_H; y++) {
        for (unsigned x = 0; x < TC_W; x++) {
            unsigned r = (x & 0x1F);
            unsigned g = (y & 0x3F) >> 1;
            unsigned b = ((x + bar) & 0x1F);

            if ((x / 32 + y / 32) & 1) {
                r ^= 0x1F;
                b ^= 0x1F;
            }

            s_fb[y * TC_W + x] = (uint16_t)((r << 11) | (g << 6) | b);
        }
    }

    // A moving column, so consecutive frames differ.
    for (unsigned y = 0; y < TC_H; y++)
        s_fb[y * TC_W + bar] = 0xFFFF;
}

static void generate_audio(void)
{
    unsigned frames = TC_RATE / TC_FPS;
    unsigned period = TC_RATE / 440;
    unsigned half = period / 2;
    unsigned base = s_frame * frames;

    for (unsigned i = 0; i < frames; i++) {
        int16_t v = (((base + i) / half) & 1) ? 4000 : -4000;
        s_snd[i * 2 + 0] = v;
        s_snd[i * 2 + 1] = v;
    }
}

void retro_init(void)
{
    s_frame = 0;
}

void retro_deinit(void)
{
}

unsigned retro_api_version(void)
{
    return RETRO_API_VERSION;
}

void retro_set_environment(retro_environment_t cb)
{
    s_env = cb;
}

void retro_set_video_refresh(retro_video_refresh_t cb)
{
    s_video = cb;
}

void retro_set_audio_sample(retro_audio_sample_t cb)
{
    (void)cb;
}

void retro_set_audio_sample_batch(retro_audio_sample_batch_t cb)
{
    s_audio_batch = cb;
}

void retro_set_input_poll(retro_input_poll_t cb)
{
    s_input_poll = cb;
}

void retro_set_input_state(retro_input_state_t cb)
{
    s_input_state = cb;
}

void retro_get_system_info(struct retro_system_info *info)
{
    memset(info, 0, sizeof(*info));
    info->library_name = "retrods testcore";
    info->library_version = "1.0";
    info->valid_extensions = "rdt|testrd";
    info->need_fullpath = false;
    info->block_extract = false;
}

void retro_get_system_av_info(struct retro_system_av_info *info)
{
    memset(info, 0, sizeof(*info));
    info->geometry.base_width = TC_W;
    info->geometry.base_height = TC_H;
    info->geometry.max_width = TC_W;
    info->geometry.max_height = TC_H;
    info->geometry.aspect_ratio = 4.0f / 3.0f;
    info->timing.fps = (double)TC_FPS;
    info->timing.sample_rate = (double)TC_RATE;
}

void retro_set_controller_port_device(unsigned port, unsigned device)
{
    (void)port;
    (void)device;
}

void retro_reset(void)
{
    s_frame = 0;
}

void retro_run(void)
{
    unsigned frames = TC_RATE / TC_FPS;

    if (s_input_poll)
        s_input_poll();

    if (s_input_state &&
        s_input_state(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_A)) {
        // Button held: tilt the gradient by shifting the bar faster.
        s_frame++;
    }

    generate_audio();

#ifdef TC_AUDIO_ONLY
    // Audio path tests: skip drawing, so the frame costs next to nothing and
    // any glitch in the output is the frontend's, not a slow frame's.
    if (s_video)
        s_video(NULL, TC_W, TC_H, TC_W * sizeof(uint16_t));
#else
    render();
    if (s_video)
        s_video(s_fb, TC_W, TC_H, TC_W * sizeof(uint16_t));
#endif

    if (s_audio_batch)
        s_audio_batch(s_snd, frames);

    s_frame++;
}

bool retro_load_game(const struct retro_game_info *info)
{
    enum retro_pixel_format fmt = RETRO_PIXEL_FORMAT_RGB565;

    (void)info;

    if (s_env && s_env(RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, &fmt))
        fmt = RETRO_PIXEL_FORMAT_RGB565;

    s_loaded = true;
    s_frame = 0;
    return true;
}

bool retro_load_game_special(unsigned type, const struct retro_game_info *info, size_t num)
{
    (void)type;
    (void)info;
    (void)num;
    return false;
}

void retro_unload_game(void)
{
    s_loaded = false;
}

unsigned retro_get_region(void)
{
    return RETRO_REGION_NTSC;
}

// Save state. The animation phase is the whole of this core's state, so
// restoring it resumes the pattern exactly where it was -- which is what the
// frontend's save-state round-trip test checks. The magic makes a foreign or
// truncated file fail cleanly instead of being half-applied.
#define TC_STATE_MAGIC 0x53544452u /* "RDTS" */

struct tc_state {
    uint32_t magic;
    uint32_t frame;
    uint32_t loaded;
};

size_t retro_serialize_size(void)
{
    return sizeof(struct tc_state);
}

bool retro_serialize(void *data, size_t size)
{
    struct tc_state st;

    if (!data || size < sizeof(st))
        return false;

    st.magic = TC_STATE_MAGIC;
    st.frame = s_frame;
    st.loaded = s_loaded ? 1u : 0u;

    memcpy(data, &st, sizeof(st));
    return true;
}

bool retro_unserialize(const void *data, size_t size)
{
    const struct tc_state *st = (const struct tc_state *)data;

    if (!st || size < sizeof(*st) || st->magic != TC_STATE_MAGIC)
        return false;

    s_frame = st->frame;
    s_loaded = st->loaded != 0;
    return true;
}

void retro_cheat_reset(void)
{
}

void retro_cheat_set(unsigned index, bool enabled, const char *code)
{
    (void)index;
    (void)enabled;
    (void)code;
}

void *retro_get_memory_data(unsigned id)
{
    (void)id;
    return NULL;
}

size_t retro_get_memory_size(unsigned id)
{
    (void)id;
    return 0;
}
