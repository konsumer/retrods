// SPDX-License-Identifier: Zlib
//
// POSIX backend used by the host test harness (tests/run-host.sh). It has no
// display or sound card: frames are written as PPM, audio as WAV, and the run
// stops after RD_FRAMES frames. This exercises exactly the same frontend and
// core code that runs on the DS.

#include "../platform.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define W 256
#define H 192

static const char *s_outdir = "build-host/out";
static unsigned s_frame;
static unsigned s_max_frames = 120;

static int16_t *s_audio;
static size_t s_audio_frames;
static size_t s_audio_cap;
static unsigned s_audio_rate = 44100;

static unsigned long long s_hash = 1469598103934665603ULL;

static void hash_bytes(const void *data, size_t size)
{
    const uint8_t *p = data;
    for (size_t i = 0; i < size; i++) {
        s_hash ^= p[i];
        s_hash *= 1099511628211ULL;
    }
}

bool rd_plat_init(void)
{
    const char *env;

    env = getenv("RD_OUTDIR");
    if (env)
        s_outdir = env;

    env = getenv("RD_FRAMES");
    if (env)
        s_max_frames = (unsigned)strtoul(env, NULL, 10);

    return true;
}

void rd_plat_deinit(void)
{
    char path[512];
    FILE *f;

    if (!s_audio || !s_audio_frames)
        return;

    snprintf(path, sizeof(path), "%s/audio.wav", s_outdir);
    f = fopen(path, "wb");
    if (!f) {
        fprintf(stderr, "retrods: cannot write %s\n", path);
        return;
    }

    {
        uint32_t data_size = (uint32_t)(s_audio_frames * 2 * sizeof(int16_t));
        uint32_t chunk_size = 36 + data_size;
        uint32_t byte_rate = s_audio_rate * 2 * 2;
        uint16_t block_align = 2 * 2;

        fwrite("RIFF", 1, 4, f);
        fwrite(&chunk_size, 4, 1, f);
        fwrite("WAVEfmt ", 1, 8, f);
        { uint32_t v = 16; fwrite(&v, 4, 1, f); }
        { uint16_t v = 1;  fwrite(&v, 2, 1, f); }
        { uint16_t v = 2;  fwrite(&v, 2, 1, f); }
        fwrite(&s_audio_rate, 4, 1, f);
        fwrite(&byte_rate, 4, 1, f);
        { uint16_t v = block_align; fwrite(&v, 2, 1, f); }
        { uint16_t v = 16; fwrite(&v, 2, 1, f); }
        fwrite("data", 1, 4, f);
        fwrite(&data_size, 4, 1, f);
        fwrite(s_audio, 2, s_audio_frames * 2, f);
    }

    fclose(f);

    fprintf(stderr, "retrods: wrote %s (%u frames)\n", path, (unsigned)s_audio_frames);
}

static void write_ppm(const char *path, const void *data, unsigned width,
                      unsigned height, size_t pitch, enum rd_pixel_format fmt);

void rd_plat_video(const void *data, unsigned width, unsigned height,
                   size_t pitch, enum rd_pixel_format fmt)
{
    char path[512];

    s_frame++;

    if (!data) {
        fprintf(stderr, "retrods: frame %u duplicated\n", s_frame);
        return;
    }

    hash_bytes(data, pitch * height);

    // Dump a sparse selection of frames to keep the harness fast.
    if (s_frame != 1 && s_frame != 2 && (s_frame % 30) != 0)
        return;

    snprintf(path, sizeof(path), "%s/frame_%04u.ppm", s_outdir, s_frame);
    write_ppm(path, data, width, height, pitch, fmt);
}

void rd_plat_screenshot(const void *data, unsigned width, unsigned height,
                        size_t pitch, enum rd_pixel_format fmt,
                        const char *base_path)
{
    char path[512];

    snprintf(path, sizeof(path), "%s.ppm", base_path);
    write_ppm(path, data, width, height, pitch, fmt);
    fprintf(stderr, "retrods: screenshot %s\n", path);
}

static void write_ppm(const char *path, const void *data, unsigned width,
                      unsigned height, size_t pitch, enum rd_pixel_format fmt)
{
    FILE *f;
    unsigned bpp = (fmt == RD_PIXEL_XRGB8888) ? 4 : 2;

    f = fopen(path, "wb");
    if (!f)
        return;

    fprintf(f, "P6\n%u %u\n255\n", width, height);

    for (unsigned y = 0; y < height; y++) {
        const uint8_t *row = (const uint8_t *)data + (size_t)y * pitch;
        for (unsigned x = 0; x < width; x++) {
            const uint8_t *p = row + (size_t)x * bpp;
            uint8_t rgb[3];

            if (fmt == RD_PIXEL_XRGB8888) {
                rgb[0] = p[2];
                rgb[1] = p[1];
                rgb[2] = p[0];
            } else if (fmt == RD_PIXEL_RGB565) {
                unsigned v = (unsigned)p[0] | ((unsigned)p[1] << 8);
                rgb[0] = (uint8_t)(((v >> 11) & 0x1F) * 255 / 31);
                rgb[1] = (uint8_t)(((v >> 5) & 0x3F) * 255 / 63);
                rgb[2] = (uint8_t)((v & 0x1F) * 255 / 31);
            } else {
                unsigned v = (unsigned)p[0] | ((unsigned)p[1] << 8);
                rgb[0] = (uint8_t)(((v >> 10) & 0x1F) * 255 / 31);
                rgb[1] = (uint8_t)(((v >> 5) & 0x1F) * 255 / 31);
                rgb[2] = (uint8_t)((v & 0x1F) * 255 / 31);
            }

            fwrite(rgb, 1, 3, f);
        }
    }

    fclose(f);
}

void rd_plat_audio(const int16_t *stereo, size_t frames, unsigned sample_rate)
{
    s_audio_rate = sample_rate;

    if (s_audio_frames + frames > s_audio_cap) {
        size_t cap = s_audio_cap ? s_audio_cap * 2 : 65536;
        int16_t *grown;

        while (cap < s_audio_frames + frames)
            cap *= 2;

        grown = realloc(s_audio, cap * 2 * sizeof(int16_t));
        if (!grown)
            return;

        s_audio = grown;
        s_audio_cap = cap;
    }

    memcpy(s_audio + s_audio_frames * 2, stereo, frames * 2 * sizeof(int16_t));
    s_audio_frames += frames;
    hash_bytes(stereo, frames * 2 * sizeof(int16_t));
}

// The harness has no input device, but the hotkeys have to be testable, so
// RD_INPUT scripts button combos by frame number:
//
//     RD_INPUT="60:save,120:load,180:shot,90-120:fast,200-260:start"
//
// each entry being "<frame>:<action>" or "<first>-<last>:<action>". The named
// combo is applied for exactly those frames, which is what a real press looks
// like to the frontend's edge detection.
//
// RETRO_DEVICE_ID_JOYPAD_* values; this file does not include libretro.h.
#define RD_JOY_B      0
#define RD_JOY_Y      1
#define RD_JOY_SELECT 2
#define RD_JOY_START  3
#define RD_JOY_A      8
#define RD_JOY_X      9
#define RD_JOY_L      10
#define RD_JOY_R      11

#define RD_INPUT_MAX 16

struct rd_input_step {
    unsigned first, last;
    unsigned buttons[8];
    unsigned count;
};

static struct rd_input_step s_input[RD_INPUT_MAX];
static unsigned s_input_len;
static unsigned s_input_frame;
static uint32_t s_buttons;
static uint32_t s_held;
static bool s_input_ready;

static void input_add(unsigned first, unsigned last, const char *action)
{
    struct rd_input_step *st;
    unsigned n = 0;

    if (s_input_len >= RD_INPUT_MAX)
        return;

    st = &s_input[s_input_len];
    st->first = first;
    st->last = last;

    /* Every hotkey is held with L+R; quit is the platform's four-button combo. */
    if (strcmp(action, "quit") != 0) {
        if (!strcmp(action, "save") || !strcmp(action, "load") ||
            !strcmp(action, "shot") || !strcmp(action, "fast")) {
            st->buttons[n++] = RD_JOY_L;
            st->buttons[n++] = RD_JOY_R;
        }
    }
    if (!strcmp(action, "save"))   st->buttons[n++] = RD_JOY_START;
    if (!strcmp(action, "load"))   st->buttons[n++] = RD_JOY_SELECT;
    if (!strcmp(action, "shot"))   st->buttons[n++] = RD_JOY_X;
    if (!strcmp(action, "fast"))   st->buttons[n++] = RD_JOY_A;
    /* Plain button names, for testing that a core actually receives input:
       RD_INPUT="60-90:start" holds START across those frames. */
    if (!strcmp(action, "a"))      st->buttons[n++] = RD_JOY_A;
    if (!strcmp(action, "b"))      st->buttons[n++] = RD_JOY_B;
    if (!strcmp(action, "x"))      st->buttons[n++] = RD_JOY_X;
    if (!strcmp(action, "y"))      st->buttons[n++] = RD_JOY_Y;
    if (!strcmp(action, "start"))  st->buttons[n++] = RD_JOY_START;
    if (!strcmp(action, "select")) st->buttons[n++] = RD_JOY_SELECT;
    if (!strcmp(action, "up"))     st->buttons[n++] = 4;
    if (!strcmp(action, "down"))   st->buttons[n++] = 5;
    if (!strcmp(action, "left"))   st->buttons[n++] = 6;
    if (!strcmp(action, "right"))  st->buttons[n++] = 7;
    if (!strcmp(action, "quit")) {
        st->buttons[n++] = RD_JOY_L;
        st->buttons[n++] = RD_JOY_R;
        st->buttons[n++] = RD_JOY_START;
        st->buttons[n++] = RD_JOY_SELECT;
    }

    if (!n)
        return;

    st->count = n;
    s_input_len++;
}

static void input_parse(void)
{
    const char *env = getenv("RD_INPUT");
    char spec[512], *entry;

    s_input_ready = true;
    if (!env || !*env)
        return;

    snprintf(spec, sizeof(spec), "%s", env);

    for (entry = strtok(spec, ","); entry; entry = strtok(NULL, ",")) {
        char *colon = strchr(entry, ':');
        char *dash;
        unsigned first, last;

        if (!colon)
            continue;
        *colon++ = '\0';

        dash = strchr(entry, '-');
        if (dash) {
            *dash++ = '\0';
            last = (unsigned)strtoul(dash, NULL, 10);
        } else {
            last = (unsigned)strtoul(entry, NULL, 10);
        }
        first = (unsigned)strtoul(entry, NULL, 10);
        if (last < first)
            last = first;

        input_add(first, last, colon);
    }
}

void rd_plat_poll_input(void)
{
    unsigned i, j;

    if (!s_input_ready)
        input_parse();

    s_input_frame++;

    for (i = 0; i < s_input_len; i++) {
        const struct rd_input_step *st = &s_input[i];
        if (s_input_frame < st->first || s_input_frame > st->last)
            continue;
        for (j = 0; j < st->count; j++)
            s_buttons |= 1u << st->buttons[j];
    }

    /* one frame is one press: clear before the next poll */
    s_held = s_buttons;
    s_buttons = 0;
}

bool rd_plat_button(unsigned id)
{
    return id < 32 && (s_held & (1u << id)) != 0;
}

void rd_plat_wait_frame(void)
{
    /* The harness has no frame boundary to wait for. */
}

bool rd_plat_quit_requested(void)
{
    return s_frame >= s_max_frames;
}

void rd_plat_log(const char *s)
{
    fprintf(stderr, "retrods: %s\n", s);
}

void rd_plat_status(const char *s)
{
    (void)s;
}

// Same layout as the DS: firmware next to the binary under test. The env
// overrides let the harness point at a firmware tree elsewhere.
#define RD_PATH_MAX 512
static char s_system_dir[RD_PATH_MAX] = "build-host/bios";
static char s_save_dir[RD_PATH_MAX] = "build-host/saves";

void rd_plat_set_program_path(const char *argv0)
{
    const char *slash;
    size_t len;

    if (argv0 != NULL && (slash = strrchr(argv0, '/')) != NULL) {
        len = (size_t)(slash - argv0);
        if (len > 0 && len < sizeof(s_system_dir) - 6) {
            snprintf(s_system_dir, sizeof(s_system_dir), "%.*s/bios", (int)len, argv0);
            snprintf(s_save_dir, sizeof(s_save_dir), "%.*s/saves", (int)len, argv0);
        } else if (len == 0) {
            snprintf(s_system_dir, sizeof(s_system_dir), "/bios");
            snprintf(s_save_dir, sizeof(s_save_dir), "/saves");
        }
    }
}

const char *rd_plat_system_dir(void)
{
    const char *env = getenv("RD_SYSTEM_DIR");
    return (env && *env) ? env : s_system_dir;
}

const char *rd_plat_save_dir(void)
{
    const char *env = getenv("RD_SAVE_DIR");
    return (env && *env) ? env : s_save_dir;
}

void rd_plat_hold(const char *msg)
{
    if (msg)
        rd_plat_log(msg);
}

void *rd_plat_read_file(const char *path, size_t *size_out)
{
    FILE *f = fopen(path, "rb");
    long size;
    void *buf;

    if (!f)
        return NULL;

    if (fseek(f, 0, SEEK_END) != 0) {
        fclose(f);
        return NULL;
    }

    size = ftell(f);
    if (size <= 0) {
        fclose(f);
        return NULL;
    }

    rewind(f);

    buf = malloc((size_t)size);
    if (!buf) {
        fclose(f);
        return NULL;
    }

    if (fread(buf, 1, (size_t)size, f) != (size_t)size) {
        free(buf);
        fclose(f);
        return NULL;
    }

    fclose(f);

    if (size_out)
        *size_out = (size_t)size;

    return buf;
}

bool rd_plat_write_file(const char *path, const void *data, size_t size)
{
    FILE *f = fopen(path, "wb");
    bool ok;

    if (!f)
        return false;

    ok = fwrite(data, 1, size, f) == size;
    fclose(f);

    return ok;
}

bool rd_plat_file_exists(const char *path)
{
    FILE *f = fopen(path, "rb");

    if (!f)
        return false;

    fclose(f);
    return true;
}
