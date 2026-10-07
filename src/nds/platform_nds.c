// SPDX-License-Identifier: Zlib
//
// Nintendo DS / DSi platform backend: main-screen framebuffer via the 2D
// engine, ARM7 sound streaming, keypad input and libfat file access.

#include "../platform.h"

#include <fat.h>
#include <nds.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define FB_W 256
#define FB_H 192

// Audio is streamed to the ARM7 in fixed-size chunks. One chunk per sound
// channel, rotated, so the ARM7 never reads a buffer we are writing into.
#define SND_CHUNK_FRAMES 1024
#define SND_CHUNKS       8

static uint16_t s_fb[FB_W * FB_H] __attribute__((aligned(4)));
static int16_t s_snd[SND_CHUNKS][SND_CHUNK_FRAMES * 2] __attribute__((aligned(4)));
static size_t s_snd_frames;
static unsigned s_snd_chunk;
static unsigned s_snd_rate = 44100;

static bool s_quit;
static uint16_t s_colmap[256];
static unsigned s_colmap_w, s_colmap_h;
static bool s_joy[16];

// Key mapping, indexed by RETRO_DEVICE_ID_JOYPAD_* value.
static const uint16_t s_keymap[16] = {
    KEY_B, KEY_Y, KEY_SELECT, KEY_START,
    KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT,
    KEY_A, KEY_X, KEY_L, KEY_R,
    0, 0, 0, 0,
};

static uint16_t convert(const uint8_t *p, enum rd_pixel_format fmt)
{
    uint32_t v;
    unsigned r, g, b;

    switch (fmt) {
    case RD_PIXEL_RGB565:
        v = (uint32_t)p[0] | ((uint32_t)p[1] << 8);
        r = (v >> 11) & 0x1F;
        g = (v >> 6) & 0x1F;
        b = v & 0x1F;
        break;

    case RD_PIXEL_XRGB8888:
        v = (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
            ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
        r = (v >> 19) & 0x1F;
        g = (v >> 11) & 0x1F;
        b = (v >> 3) & 0x1F;
        break;

    case RD_PIXEL_0RGB1555:
    default:
        v = (uint32_t)p[0] | ((uint32_t)p[1] << 8);
        r = (v >> 10) & 0x1F;
        g = (v >> 5) & 0x1F;
        b = v & 0x1F;
        break;
    }

    // The DS framebuffer is BGR555.
    return (uint16_t)((b << 10) | (g << 5) | r);
}

// picolibc on the DS has no kernel sleep, but libretro-common's retro_timers.h
// calls nanosleep(). Busy-wait on the ARM9 cycle counter instead; nothing in the
// frontend uses it for pacing (frames are paced by swiWaitForVBlank).
int nanosleep(const struct timespec *req, struct timespec *rem)
{
    long long us;

    if (rem) {
        rem->tv_sec = 0;
        rem->tv_nsec = 0;
    }
    if (!req)
        return 0;

    us = (long long)req->tv_sec * 1000000 + req->tv_nsec / 1000;
    while (us > 0) {
        unsigned step = us > 1000 ? 1000 : (unsigned)us;
        swiDelay(step * 12); /* ~12 ARM9 cycles per microsecond (67/133 MHz) */
        us -= step;
    }
    return 0;
}

bool rd_plat_init(void)
{
    // Bring the display and console up first: if anything below fails, the
    // error is then visible instead of a black screen.
    videoSetMode(MODE_FB0);
    vramSetBankA(VRAM_A_LCD);
    setBackdropColor(RGB15(0, 0, 0));
    consoleDemoInit();

    soundEnable();

    // libfat is backed by the DLDI driver that Pico Loader patches into
    // homebrew at launch time.
    if (!fatInitDefault())
        return false;

    return true;
}

// Firmware and saves live next to the .nds, so one directory on the SD card is
// the whole deployment:
//
//     apps/retrods-quicknes.nds
//     apps/bios/o2rom.bin
//     apps/bios/voice/E480.WAV
//     apps/saves/
//
#define RD_PATH_MAX 512
static char s_base_dir[RD_PATH_MAX] = "fat:";
static char s_system_dir[RD_PATH_MAX] = "fat:/bios";
static char s_save_dir[RD_PATH_MAX] = "fat:/saves";

void rd_plat_set_program_path(const char *argv0)
{
    const char *slash;
    size_t len;
    char tmp[RD_PATH_MAX];

    if (argv0 != NULL && (slash = strrchr(argv0, '/')) != NULL && slash != argv0) {
        len = (size_t)(slash - argv0);
        if (len < sizeof(tmp)) {
            snprintf(tmp, sizeof(tmp), "%.*s", (int)len, argv0);
            /* Pico Launcher passes "fat:/apps/..."; a bare "/apps/..." still
             * needs the device prefix libfat expects. */
            if (tmp[0] == '/' && strchr(tmp, ':') == NULL)
                snprintf(s_base_dir, sizeof(s_base_dir), "fat:%s", tmp);
            else
                snprintf(s_base_dir, sizeof(s_base_dir), "%s", tmp);
        }
    }

    snprintf(s_system_dir, sizeof(s_system_dir), "%s/bios", s_base_dir);
    snprintf(s_save_dir, sizeof(s_save_dir), "%s/saves", s_base_dir);
}

const char *rd_plat_system_dir(void)
{
    return s_system_dir;
}

const char *rd_plat_save_dir(void)
{
    return s_save_dir;
}

void rd_plat_hold(const char *msg)
{
    if (msg)
        rd_plat_log(msg);

    printf("\npress START to exit\n");

    for (;;) {
        swiWaitForVBlank();
        scanKeys();
        if (keysDown() & KEY_START)
            break;
    }
}

void rd_plat_deinit(void)
{
    soundDisable();
}

void rd_plat_video(const void *data, unsigned width, unsigned height,
                   size_t pitch, enum rd_pixel_format fmt)
{
    unsigned scale, sy, dw, dh, ox, oy, bpp;

    if (!data || !width || !height)
        return;

    scale = ((unsigned)FB_W << 16) / width;
    sy = ((unsigned)FB_H << 16) / height;
    if (sy < scale)
        scale = sy;
    if (!scale)
        scale = 1;

    dw = (unsigned)(((uint64_t)width * scale) >> 16);
    dh = (unsigned)(((uint64_t)height * scale) >> 16);
    if (dw > FB_W)
        dw = FB_W;
    if (dh > FB_H)
        dh = FB_H;

    ox = (FB_W - dw) / 2;
    oy = (FB_H - dh) / 2;
    bpp = (fmt == RD_PIXEL_XRGB8888) ? 4 : 2;

    if (width != s_colmap_w || height != s_colmap_h) {
        /* The column mapping only changes when the geometry does, so build it
           once: the inner loop then costs a table read instead of a 64-bit
           divide per pixel, which matters at 67 MHz. */
        for (unsigned x = 0; x < width; x++) {
            unsigned sx = (unsigned)(((uint64_t)x << 16) / scale);
            if (sx >= width)
                sx = width - 1;
            s_colmap[x] = (uint16_t)sx;
        }
        s_colmap_w = width;
        s_colmap_h = height;
    }

    memset(s_fb, 0, sizeof(s_fb));

    for (unsigned y = 0; y < dh; y++) {
        unsigned srow = (unsigned)(((uint64_t)y << 16) / scale);
        const uint8_t *src;
        uint16_t *dst;

        if (srow >= height)
            srow = height - 1;

        src = (const uint8_t *)data + (size_t)srow * pitch;
        dst = s_fb + (size_t)(oy + y) * FB_W + ox;

        for (unsigned x = 0; x < dw; x++)
            dst[x] = convert(src + (size_t)s_colmap[x] * bpp, fmt);
    }

    dmaCopy(s_fb, VRAM_A, sizeof(s_fb));
}

// Screenshots go out as 24-bit BMP: the DS has no image encoder, and a BMP
// needs none. Rows are bottom-up and padded to four bytes, as BMP requires.
void rd_plat_screenshot(const void *data, unsigned width, unsigned height,
                        size_t pitch, enum rd_pixel_format fmt,
                        const char *base_path)
{
    char path[256];
    unsigned bpp = (fmt == RD_PIXEL_XRGB8888) ? 4 : 2;
    unsigned row_bytes = (width * 3 + 3) & ~3u;
    uint32_t file_size = 54 + row_bytes * height;
    uint8_t header[54];
    FILE *f;

    snprintf(path, sizeof(path), "%s.bmp", base_path);
    f = fopen(path, "wb");
    if (!f) {
        printf("screenshot: could not write %s\n", path);
        return;
    }

    memset(header, 0, sizeof(header));
    header[0] = 'B';
    header[1] = 'M';
    memcpy(header + 2, &file_size, 4);
    *(uint32_t *)(header + 10) = 54;
    *(uint32_t *)(header + 14) = 40;
    *(int32_t *)(header + 18) = (int32_t)width;
    *(int32_t *)(header + 22) = (int32_t)height;
    *(uint16_t *)(header + 26) = 1;
    *(uint16_t *)(header + 28) = 24;
    *(uint32_t *)(header + 34) = row_bytes * height;
    fwrite(header, 1, sizeof(header), f);

    for (unsigned y = 0; y < height; y++) {
        const uint8_t *row = (const uint8_t *)data + (size_t)(height - 1 - y) * pitch;
        uint8_t pad[3] = { 0, 0, 0 };
        unsigned written = 0;

        for (unsigned x = 0; x < width; x++) {
            uint16_t rgb555 = convert(row + (size_t)x * bpp, fmt);
            uint8_t bgr[3];

            /* convert() returns BGR555 in DS order; expand to 8 bits each. */
            bgr[0] = (uint8_t)((rgb555 & 0x1F) * 255 / 31);
            bgr[1] = (uint8_t)(((rgb555 >> 5) & 0x1F) * 255 / 31);
            bgr[2] = (uint8_t)(((rgb555 >> 10) & 0x1F) * 255 / 31);
            fwrite(bgr, 1, 3, f);
            written += 3;
        }
        while (written < row_bytes) {
            fwrite(pad, 1, 1, f);
            written++;
        }
    }

    fclose(f);
    printf("screenshot: %s\n", path);
}

static void flush_audio_chunk(void)
{
    if (!s_snd_frames)
        return;

    soundPlaySampleChannel((int)s_snd_chunk, s_snd[s_snd_chunk], SoundFormat_16Bit,
                           (u32)(s_snd_frames * 2 * sizeof(int16_t)),
                           (u16)s_snd_rate, 127, 64, false, 0);

    s_snd_chunk = (s_snd_chunk + 1) % SND_CHUNKS;
    s_snd_frames = 0;
}

void rd_plat_audio(const int16_t *stereo, size_t frames, unsigned sample_rate)
{
    s_snd_rate = sample_rate;

    while (frames > 0) {
        size_t space = SND_CHUNK_FRAMES - s_snd_frames;
        size_t n = frames < space ? frames : space;

        memcpy(s_snd[s_snd_chunk] + s_snd_frames * 2, stereo,
               n * 2 * sizeof(int16_t));
        s_snd_frames += n;
        stereo += n * 2;
        frames -= n;

        if (s_snd_frames == SND_CHUNK_FRAMES)
            flush_audio_chunk();
    }
}

void rd_plat_poll_input(void)
{
    // libnds only refreshes the key state when scanKeys() is called: without
    // this, keysHeld() returns whatever was scanned last, which before the
    // first hold screen is nothing at all. That is why no core saw any input.
    scanKeys();

    uint16_t keys = keysHeld();

    for (unsigned i = 0; i < 16; i++)
        s_joy[i] = s_keymap[i] && (keys & s_keymap[i]);

    if ((keys & (KEY_L | KEY_R | KEY_START | KEY_SELECT)) ==
        (KEY_L | KEY_R | KEY_START | KEY_SELECT))
        s_quit = true;
}

bool rd_plat_button(unsigned id)
{
    return id < 16 ? s_joy[id] : false;
}

void rd_plat_wait_frame(void)
{
    swiWaitForVBlank();
}

bool rd_plat_quit_requested(void)
{
    return s_quit;
}

void rd_plat_log(const char *s)
{
    printf("%s\n", s);
}

void rd_plat_status(const char *s)
{
    printf("\x1b[0;0H%s\n", s);
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
