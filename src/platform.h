// SPDX-License-Identifier: Zlib
//
// Platform abstraction for retrods. Each target (Nintendo DS, POSIX host test
// harness) implements these functions.

#ifndef RETRODS_PLATFORM_H
#define RETRODS_PLATFORM_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// Pixel formats, mirrored from libretro.h so that backends don't need to pull
// in the full header.
enum rd_pixel_format {
    RD_PIXEL_0RGB1555 = 0,
    RD_PIXEL_XRGB8888 = 1,
    RD_PIXEL_RGB565   = 2,
};

// One-time per-process setup. Returns false on a fatal error.
bool rd_plat_init(void);
void rd_plat_deinit(void);

// Present one emulator frame. `data` may be NULL when the core reports a
// duplicate of the previous frame.
void rd_plat_video(const void *data, unsigned width, unsigned height,
                   size_t pitch, enum rd_pixel_format fmt);

// Feed interleaved stereo signed-16 samples.
void rd_plat_audio(const int16_t *stereo, size_t frames, unsigned sample_rate);

// Write one frame as an image, appending the platform's own extension to
// `base_path` (PPM on the host, BMP on the DS, which has no encoder).
void rd_plat_screenshot(const void *data, unsigned width, unsigned height,
                        size_t pitch, enum rd_pixel_format fmt,
                        const char *base_path);

// Per-frame input. `id` is a RETRO_DEVICE_ID_JOYPAD_* value.
void rd_plat_poll_input(void);
bool rd_plat_button(unsigned id);

// Block until the next frame boundary (vblank on the DS).
void rd_plat_wait_frame(void);

// True once the user has asked to quit (button combo, or the host harness
// reaching its frame budget).
bool rd_plat_quit_requested(void);

void rd_plat_log(const char *s);
void rd_plat_status(const char *s);

// Called before the frontend gives up (fatal error) or after a normal exit.
// On the DS this keeps the message on screen until the user presses START so
// it isn't lost when control returns to the launcher; on the host it is a
// no-op.
void rd_plat_hold(const char *msg);

// Tell the platform where the running .nds lives (argv[0]). Both directories
// are derived from it so a deployment is self-contained: the firmware sits in
// <app dir>/bios next to the apps that need it, and saves go to
// <app dir>/saves.
void rd_plat_set_program_path(const char *argv0);

// Where cores look for BIOS/firmware and where saves go: "<app dir>/bios" and
// "<app dir>/saves" unless overridden. The host harness also honours
// RD_SYSTEM_DIR / RD_SAVE_DIR so firmware can live outside the build tree.
const char *rd_plat_system_dir(void);
const char *rd_plat_save_dir(void);

// Minimal file helpers, used to read ROMs and persist SRAM.
void *rd_plat_read_file(const char *path, size_t *size_out);
bool rd_plat_write_file(const char *path, const void *data, size_t size);
bool rd_plat_file_exists(const char *path);

#endif // RETRODS_PLATFORM_H
