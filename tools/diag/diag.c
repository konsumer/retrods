// SPDX-License-Identifier: Zlib
//
// retrods diagnostic. Measures the DS subsystems the frontend depends on and
// writes the numbers to fat:/diag.txt, because guessing at a 67 MHz ARM9 from a
// screenshot is how the missing scanKeys() survived for weeks.
//
// Not an emulator: this is a plain libnds app, built the same way as the apps
// so the numbers describe the same code paths.

#include <nds.h>
#include <fat.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <sys/stat.h>

static FILE *g_log;

static void say(const char *fmt, ...)
{
    char line[192];
    va_list ap;

    va_start(ap, fmt);
    vsnprintf(line, sizeof(line), fmt, ap);
    va_end(ap);

    printf("%s\n", line);
    if (g_log) {
        fprintf(g_log, "%s\n", line);
        fflush(g_log);
    }
}

// --- timing: TIMER0 at 524288 Hz (1.9 us a tick, wraps every 125 ms) -------
static void t_start(void) { timerStart(0, ClockDivider_64, 0, NULL); }

static void bench_loop(void)
{
    volatile u32 x = 1;
    for (u32 i = 0; i < 1000000u; i++)
        x = x * 1664525u + 1013904223u;
    (void)x;
}

// Our current CPU blit, so the number is the real one and not an estimate.
static void bench_blit(unsigned w, unsigned h)
{
    static u16 fb[256 * 192];
    static u16 src[320 * 240];
    size_t pitch = w * 2;
    u32 start, dur;

    for (unsigned i = 0; i < w * h; i++)
        src[i] = (u16)(i * 7 + 0x1234);

    t_start();
    start = (u32)TIMER_DATA(0);

    for (int rep = 0; rep < 10; rep++) {
        unsigned scale = ((unsigned)256 << 16) / w;
        unsigned sy = ((unsigned)192 << 16) / h;
        if (sy < scale) scale = sy;
        unsigned dw = (unsigned)(((unsigned long long)w * scale) >> 16);
        unsigned dh = (unsigned)(((unsigned long long)h * scale) >> 16);
        unsigned ox = (256 - dw) / 2, oy = (192 - dh) / 2;

        memset(fb, 0, sizeof(fb));
        for (unsigned y = 0; y < dh; y++) {
            unsigned srow = (unsigned)(((unsigned long long)y << 16) / scale);
            const u16 *s = src + (size_t)srow * w;
            u16 *d = fb + (size_t)(oy + y) * 256 + ox;
            for (unsigned x = 0; x < dw; x++) {
                unsigned sx = (unsigned)(((unsigned long long)x << 16) / scale);
                d[x] = s[sx];
            }
        }
    }

    dur = (u32)TIMER_DATA(0) - start;
    say("blit %ux%u -> 256x192: %lu us/frame", w, h,
        (unsigned long)((u64)dur * 1000000ull / 524288ull / 10));
    (void)pitch;
}

static void bench_dma(void)
{
    static u16 fb[256 * 192];
    u32 start, dur;

    t_start();
    start = (u32)TIMER_DATA(0);
    for (int i = 0; i < 10; i++)
        dmaCopy(fb, VRAM_A, sizeof(fb));
    dur = (u32)TIMER_DATA(0) - start;
    say("dmaCopy 98 KiB: %lu us", (unsigned long)((u64)dur * 1000000ull / 524288ull / 10));
}

static void bench_audio(void)
{
    static int16_t buf[1024 * 2];
    u32 start, dur;

    soundEnable();
    for (unsigned i = 0; i < 1024; i++) {
        buf[i * 2] = (int16_t)(i * 31);
        buf[i * 2 + 1] = (int16_t)(i * 31);
    }

    t_start();
    start = (u32)TIMER_DATA(0);
    // 60 chunks: a second's worth at our 8-chunk x 1024-frame rotation
    for (unsigned i = 0; i < 60; i++) {
        soundPlaySampleChannel(i % 8, buf, SoundFormat_16Bit,
                               sizeof(buf), 44100, 127, 64, false, 0);
    }
    dur = (u32)TIMER_DATA(0) - start;
    say("audio: 60 chunk starts in %lu us (a frame has 16666)",
        (unsigned long)((u64)dur * 1000000ull / 524288ull));
}

static void bench_memory(void)
{
    // newlib's malloc can return space that is not backed by real RAM on a DS,
    // so an allocation is only counted when every page of it accepts a write.
    size_t lo = 0, hi = 8u << 20, best = 0;

    for (int i = 0; i < 22; i++) {
        size_t mid = (lo + hi) / 2;
        unsigned char *p = malloc(mid);
        bool usable = false;

        if (p) {
            usable = true;
            for (size_t off = 0; off + 4096 <= mid; off += 4096) {
                p[off] = 0x5A;
                if (p[off] != 0x5A) { usable = false; break; }
            }
            free(p);
        }

        if (usable) { best = mid; lo = mid; } else { hi = mid; }
    }
    say("largest usable malloc: %lu KiB", (unsigned long)(best / 1024));
}

static void bench_sd(void)
{
    static const char *dirs[] = { "fat:/roms/gba", "fat:/roms/snes", "fat:/roms/nes", NULL };
    char path[512] = "";
    struct stat st;
    struct dirent *e;

    for (int i = 0; dirs[i] && !path[0]; i++) {
        DIR *d = opendir(dirs[i]);
        if (!d) continue;
        while ((e = readdir(d))) {
            char p[512];
            if (e->d_name[0] == '.') continue;
            snprintf(p, sizeof(p), "%s/%s", dirs[i], e->d_name);
            if (stat(p, &st) == 0 && st.st_size > (1 << 20)) {
                snprintf(path, sizeof(path), "%s", p);
                break;
            }
        }
        closedir(d);
    }

    if (!path[0]) {
        say("sd read: no file over 1 MiB found to read");
        return;
    }

    FILE *f = fopen(path, "rb");
    if (!f) { say("sd read: open failed: %s", path); return; }

    size_t cap = 1u << 20;
    void *buf = malloc(cap);
    if (buf) {
        u32 start, dur;
        size_t n;

        timerStart(0, ClockDivider_1024, 0, NULL);
        start = (u32)TIMER_DATA(0);
        n = fread(buf, 1, cap, f);
        dur = (u32)TIMER_DATA(0) - start;

        if (dur > 0)
            say("sd read: %lu KiB in %lu us = %lu KiB/s  (%s)",
                (unsigned long)(n / 1024),
                (unsigned long)((u64)dur * 1000000ull / 32768ull),
                (unsigned long)((u64)n * 32768ull / dur / 1024),
                path);
        free(buf);
    }
    fclose(f);
}

// The frontend's own frame: read input, run a frame, upload video, push audio.
// Whatever this costs comes off the top of every core's budget.
static void bench_frame(void)
{
    static u16 fb[256 * 192];
    u32 start, dur;
    unsigned frames = 0;

    // Divider 1024 (32768 Hz): TIMER0 is 16-bit, so at divider 64 it wraps
    // every 0.125 s and a quarter-second threshold can never be reached --
    // which is what made this loop forever. The frame cap means a broken
    // timer degrades the measurement instead of hanging the app.
    timerStart(0, ClockDivider_1024, 0, NULL);
    start = (u32)TIMER_DATA(0);
    while (frames < 30000 && (u32)TIMER_DATA(0) - start < 32768u / 4) {
        scanKeys();
        (void)keysHeld();
        memset(fb, frames, sizeof(fb));
        dmaCopy(fb, VRAM_A, sizeof(fb));
        frames++;
    }
    dur = (u32)TIMER_DATA(0) - start;
    if (frames)
        say("frontend overhead: %lu us/frame of a 16666 us budget (%lu fps ceiling)",
            (unsigned long)((u64)dur * 1000000ull / 32768ull / frames),
            (unsigned long)(frames * 4));
}

int main(void)
{
    videoSetMode(MODE_FB0);
    vramSetBankA(VRAM_A_LCD);
    setBackdropColor(RGB15(0, 0, 0));
    consoleDemoInit();
    soundEnable();

    bool fat = fatInitDefault();

    g_log = fat ? fopen("fat:/diag.txt", "wb") : NULL;

    say("retrods diagnostic");
    say("libfat: %s", fat ? "mounted" : "FAILED");
    say("");

    // 1. the one that mattered
    say("== input ==");
    say("hold buttons: their names appear below. If nothing does,");
    say("the keypad is not being scanned.");
    say("");

    say("== vblank ==");
    {
        u32 start, dur;
        unsigned frames = 0;
        timerStart(0, ClockDivider_1024, 0, NULL);   // 32768 Hz, wraps at 2 s
        start = (u32)TIMER_DATA(0);
        while ((u32)TIMER_DATA(0) - start < 32768u / 2) {   // half a second
            swiWaitForVBlank();
            frames++;
        }
        dur = (u32)TIMER_DATA(0) - start;
        say("vblank: %lu frames in %lu us = %lu.%02lu Hz", (unsigned long)frames,
            (unsigned long)((u64)dur * 1000000ull / 32768ull),
            (unsigned long)(frames * 2),
            (unsigned long)((frames * 200) % 100));
    }
    say("");

    say("== cpu ==");
    {
        u32 start, dur;
        t_start();
        start = (u32)TIMER_DATA(0);
        bench_loop();
        dur = (u32)TIMER_DATA(0) - start;
        say("1e6 multiply-add: %lu us",
            (unsigned long)((u64)dur * 1000000ull / 524288ull));
    }
    say("");

    say("== video ==");
    bench_blit(256, 192);
    bench_blit(320, 240);
    bench_blit(384, 272);
    bench_dma();
    say("");

    say("== audio ==");
    bench_audio();
    say("");

    say("== memory ==");
    bench_memory();
    say("");

    say("== sd ==");
    bench_sd();
    say("");

    say("== frontend frame overhead ==");
    bench_frame();
    say("");

    // The display benchmarks drew into VRAM_A; put it back rather than leaving
    // the console showing a test pattern.
    {
        static u16 blank[256 * 192];
        memset(blank, 0, sizeof(blank));
        dmaCopy(blank, VRAM_A, sizeof(blank));
    }

    say("");
    say("== results (also in /diag.txt) ==");

    // The input test comes last, as a fixed grid redrawn in place: printing it
    // as log lines would scroll the console and push the earlier results away.
    say("");
    say("== input ==");
    say("press buttons; the grid below updates. START exits.");

    static const struct { uint16_t key; const char *name; } grid[12] = {
        { KEY_UP, "UP" },       { KEY_X, "X" },
        { KEY_DOWN, "DOWN" },   { KEY_B, "B" },
        { KEY_LEFT, "LEFT" },   { KEY_Y, "Y" },
        { KEY_RIGHT, "RIGHT" }, { KEY_A, "A" },
        { KEY_L, "L" },         { KEY_R, "R" },
        { KEY_START, "START" }, { KEY_SELECT, "SELECT" },
    };

    for (unsigned row = 0; row < 6; row++) {
        uint16_t a = keysHeld() & grid[row * 2].key;
        uint16_t b = keysHeld() & grid[row * 2 + 1].key;
        printf("\x1b[%u;0H%-8s: 0          %-8s: 0", 17 + row,
               grid[row * 2].name, grid[row * 2 + 1].name);
        (void)a; (void)b;
    }

    for (;;) {
        uint16_t keys;

        swiWaitForVBlank();
        scanKeys();
        keys = keysHeld();

        for (unsigned row = 0; row < 6; row++) {
            // Redraw in place with cursor moves only: no newline, no scroll.
            printf("\x1b[%u;0H%-8s: %u", 17 + row, grid[row * 2].name,
                   (keys & grid[row * 2].key) ? 1 : 0);
            printf("\x1b[%u;18H%-8s: %u", 17 + row, grid[row * 2 + 1].name,
                   (keys & grid[row * 2 + 1].key) ? 1 : 0);
        }

        if (keysDown() & KEY_START)
            break;
    }

    if (g_log) {
        say("done");
        fclose(g_log);
    }

    return 0;
}
