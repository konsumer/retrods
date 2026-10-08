// SPDX-License-Identifier: Zlib
//
// Nintendo DS / DSi platform backend.
//
// Top screen: the core's frame, in a 16-bit bitmap background. The 2D engine's
// affine unit scales and centres it, so the CPU never scales a pixel. Frames up
// to 256 wide are double-buffered (VRAM A and B, flipped at vblank); wider ones
// get both banks as a single 512x256 bitmap.
//
// Bottom screen: a text console for logs, plus a live fps / frame-time line.
//
// Audio: one looping hardware channel over a ring buffer. A hardware timer runs
// at exactly the channel's sample rate, so its count is the play position and
// the writer can stay a fixed distance ahead of it.

#include <dirent.h>
#include <fat.h>
#include <nds.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "../platform.h"

#define SCREEN_W 256
#define SCREEN_H 192

// --- frame timing (shown on the bottom screen, see stats_frame) -------------

static volatile uint32_t s_vblanks;
static uint32_t s_vblank_seen;
static uint32_t s_frame_start;
static uint32_t s_stat_start, s_stat_vblanks;
static uint32_t s_busy_ticks, s_emu_ticks;
static unsigned s_stat_runs, s_stat_frames;

// Profiling hooks a core can be patched to call (built with -DRD_PROFILE):
// time per slot, averaged per frame and shown with the other stats.
#define PROF_SLOTS 4
static uint32_t s_prof[PROF_SLOTS];

unsigned rd_prof_now(void) {
  return cpuGetTiming();
}

void rd_prof_add(unsigned slot, unsigned ticks) {
  if (slot < PROF_SLOTS)
    s_prof[slot] += ticks;
}

// Stats lines kept for rd_plat_stats_flush(). Written to the SD only between
// runs, so measuring never stalls a frame on a card write.
#define LOGBUF_SIZE (32 * 1024)
static char s_logbuf[LOGBUF_SIZE];
static size_t s_loglen;
static unsigned s_stat_secs;

static void logbuf_printf(const char* fmt, ...) {
  va_list ap;
  int n;

  if (s_loglen >= LOGBUF_SIZE - 1)
    return;
  va_start(ap, fmt);
  n = vsnprintf(s_logbuf + s_loglen, LOGBUF_SIZE - s_loglen, fmt, ap);
  va_end(ap);
  if (n > 0)
    s_loglen += (size_t)n < LOGBUF_SIZE - s_loglen ? (size_t)n : LOGBUF_SIZE - 1 - s_loglen;
}

#ifndef RD_APP_NAME
#define RD_APP_NAME "retrods"
#endif

// --- video -------------------------------------------------------------------

#define BMP_H 256

static int s_bg = -1;
static unsigned s_bmp_w;  // 256 (double-buffered) or 512 (single)
static bool s_double;
static unsigned s_back;  // buffer the next frame is drawn into
static bool s_flip;      // a new frame is waiting in the back buffer
static unsigned s_geom_w, s_geom_h;

static uint16_t* bmp_buf(unsigned i) {
  // Map base is in 16 KiB units: 0 is VRAM A, 8 is VRAM B.
  return (uint16_t*)BG_BMP_RAM(i ? 8 : 0);
}

static uint16_t convert(const uint8_t* p, enum rd_pixel_format fmt) {
  uint32_t v;
  unsigned r, g, b;

  switch (fmt) {
    case RD_PIXEL_NATIVE:
      return (uint16_t)(p[0] | (p[1] << 8));

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

  // A DS bitmap pixel is BGR555, and bit 15 must be set or it is transparent.
  return (uint16_t)(0x8000 | (b << 10) | (g << 5) | r);
}

static void video_setup(unsigned max_w) {
  videoSetMode(MODE_5_2D);
  vramSetBankA(VRAM_A_MAIN_BG_0x06000000);
  vramSetBankB(VRAM_B_MAIN_BG_0x06020000);

  s_double = max_w <= 256;
  s_bmp_w = s_double ? 256 : 512;
  s_bg = bgInit(3, BgType_Bmp16,
                s_double ? BgSize_B16_256x256 : BgSize_B16_512x256, 0, 0);
  s_back = s_double ? 1 : 0;
  s_flip = false;
  s_geom_w = s_geom_h = 0;

  // Zero is transparent, which shows the black backdrop: the area around a
  // frame that does not fill the screen stays black.
  dmaFillWords(0, bmp_buf(0), 256 * 1024);
}

// Fit the frame to the screen, keeping its aspect ratio, centred. The affine
// matrix maps screen pixels to source pixels, in 8.8 fixed point.
static void video_geometry(unsigned w, unsigned h) {
  int sw = (int)((w << 8) + SCREEN_W - 1) / SCREEN_W;
  int sh = (int)((h << 8) + SCREEN_H - 1) / SCREEN_H;
  int s = sw > sh ? sw : sh;
  int dw = (int)(w << 8) / s;
  int dh = (int)(h << 8) / s;
  int ox = (SCREEN_W - dw) / 2;
  int oy = (SCREEN_H - dh) / 2;

  REG_BG3PA = (s16)s;
  REG_BG3PB = 0;
  REG_BG3PC = 0;
  REG_BG3PD = (s16)s;
  REG_BG3X = -ox * s;
  REG_BG3Y = -oy * s;

  // Old frames of another size would show at the edges.
  dmaFillWords(0, bmp_buf(0), 256 * 1024);

  s_geom_w = w;
  s_geom_h = h;
}

void rd_plat_video(const void* data, unsigned width, unsigned height,
                   size_t pitch, enum rd_pixel_format fmt) {
  uint16_t* dst;

  if (!data || !width || !height || s_bg < 0)
    return;

  if (width > s_bmp_w)
    width = s_bmp_w;
  if (height > BMP_H)
    height = BMP_H;
  if (width != s_geom_w || height != s_geom_h)
    video_geometry(width, height);

  s_emu_ticks += cpuGetTiming() - s_frame_start;
  s_stat_frames++;

  dst = bmp_buf(s_back);

  if (fmt == RD_PIXEL_NATIVE) {
    // DMA reads RAM, not the cache: write the core's frame back first.
    // Flushing the whole 4 KiB data cache is cheaper than flushing a range
    // as large as a frame.
    DC_FlushAll();
    for (unsigned y = 0; y < height; y++)
      dmaCopyHalfWords(3, (const uint8_t*)data + y * pitch,
                       dst + y * s_bmp_w, width * 2);
  } else {
    unsigned bpp = fmt == RD_PIXEL_XRGB8888 ? 4 : 2;

    for (unsigned y = 0; y < height; y++) {
      const uint8_t* src = (const uint8_t*)data + y * pitch;
      uint16_t* row = dst + y * s_bmp_w;

      for (unsigned x = 0; x < width; x++, src += bpp)
        row[x] = convert(src, fmt);
    }
  }

  if (s_double)
    s_flip = true;
}

// --- audio -------------------------------------------------------------------

// Hardware channels are mono, so stereo is two looping channels panned hard
// left and right, each over its own ring. A power of two that divides 65536,
// so a 16-bit timer count indexes it directly.
#define SND_RING 4096
#define SND_CH_L 0
#define SND_CH_R 1

static int16_t s_ring_mem[2][SND_RING] __attribute__((aligned(32)));
static int16_t *s_ring_l, *s_ring_r;  // uncached views of s_ring_mem
static uint16_t s_wpos;               // samples written, mod 65536
static uint16_t s_latency;
static bool s_audio_on;

// Diagnostics, shown on the bottom screen once a second.
static uint32_t s_snd_in, s_snd_under, s_snd_over;
static unsigned s_ahead_min = 0xFFFF, s_ahead_max;

static uint16_t audio_play_pos(void) {
  return TIMER_DATA(1);
}

static void audio_setup(unsigned rate) {
  if (!rate || rate > 65535)
    return;

  // The ARM7 reads RAM directly, so the rings are written through the
  // uncached mirror; flush once so no stale cached line is written back over
  // them later.
  memset(s_ring_mem, 0, sizeof(s_ring_mem));
  DC_FlushRange(s_ring_mem, sizeof(s_ring_mem));
  s_ring_l = (int16_t*)memUncached(s_ring_mem[0]);
  s_ring_r = (int16_t*)memUncached(s_ring_mem[1]);

  // ~3 frames ahead of the play position: enough to ride out a slow frame.
  s_latency = (uint16_t)(rate / 20);

  soundPlaySampleChannel(SND_CH_L, s_ring_mem[0], SoundFormat_16Bit,
                         sizeof(s_ring_mem[0]), (u16)rate, 127, 0, true, 0);
  soundPlaySampleChannel(SND_CH_R, s_ring_mem[1], SoundFormat_16Bit,
                         sizeof(s_ring_mem[1]), (u16)rate, 127, 127, true, 0);

  // TIMER0 overflows once per sample, with the same period the sound channels
  // use (their timers count at half the bus clock, hence the 2x), and TIMER1
  // counts those overflows: the samples played so far.
  TIMER_CR(0) = 0;
  TIMER_CR(1) = 0;
  // The macro's arithmetic is signed: an unsigned rate would turn the whole
  // expression unsigned and give a reload for the wrong frequency.
  TIMER_DATA(0) = (u16)(2 * TIMER_FREQ_SHIFT((int)rate, 1, 1));
  TIMER_DATA(1) = 0;
  TIMER_CR(1) = TIMER_ENABLE | TIMER_CASCADE;
  TIMER_CR(0) = TIMER_ENABLE | TIMER_DIV_1;

  s_wpos = s_latency;
  s_audio_on = true;
}

void rd_plat_audio(const int16_t* stereo, size_t frames, unsigned sample_rate) {
  uint16_t ahead;

  (void)sample_rate;

  if (!s_audio_on || !frames)
    return;

  s_snd_in += frames;
  if (frames > SND_RING / 2)
    frames = SND_RING / 2;

  ahead = (uint16_t)(s_wpos - audio_play_pos());
  if (ahead < s_ahead_min)
    s_ahead_min = ahead;
  if (ahead > s_ahead_max)
    s_ahead_max = ahead;
  if (ahead > 0x8000) {
    // Behind the play position (the core was slow): skip ahead.
    s_wpos = (uint16_t)(audio_play_pos() + s_latency);
    s_snd_under++;
  } else if (ahead + frames > SND_RING - 256) {
    // So far ahead that this would overwrite unplayed samples (the core is
    // producing faster than real time): drop it.
    s_snd_over++;
    return;
  }

  for (size_t i = 0; i < frames; i++, stereo += 2) {
    unsigned at = (s_wpos++) & (SND_RING - 1);
    s_ring_l[at] = stereo[0];
    s_ring_r[at] = stereo[1];
  }
}

// --- frame pacing and stats --------------------------------------------------

static void on_vblank(void) {
  s_vblanks++;
}

static unsigned ticks_to_us(uint64_t ticks) {
  return (unsigned)(ticks * 1000000 / BUS_CLOCK);
}

// Lines at the bottom of the console, refreshed once a second and also kept
// for retrods.log:
//
//   cpu rs au vi  per-frame ms in parts of the core, when it is built with
//                 -DRD_PROFILE and patched to call rd_prof_add()
//   play   the play position's rate, which should equal the audio rate
//   ahead  how far the writer ran ahead of it (min-max, samples)
//   run    calls to retro_run per second; new  frames that carried pixels
//   vbl    vblanks per second (the screen's own rate, ~59.8)
//   emu    ms per frame inside the core, up to its video callback
//   all    ms per frame, everything before waiting for vblank
//   snd    samples per second from the core (32768/s for gambatte at full speed)
//   u o    audio underruns (core too slow) and overruns (core too fast)
static void stats_frame(uint32_t busy) {
  uint32_t now = cpuGetTiming();
  uint32_t elapsed = now - s_stat_start;

  s_busy_ticks += busy;
  s_stat_runs++;
  if (elapsed < BUS_CLOCK)
    return;

  unsigned runs10 = (unsigned)(10ull * s_stat_runs * BUS_CLOCK / elapsed);
  unsigned new10 = (unsigned)(10ull * s_stat_frames * BUS_CLOCK / elapsed);
  unsigned vbl = (unsigned)((uint64_t)(s_vblanks - s_stat_vblanks) * BUS_CLOCK / elapsed);
  unsigned snd = (unsigned)((uint64_t)s_snd_in * BUS_CLOCK / elapsed);
  unsigned emu = ticks_to_us(s_emu_ticks) / (s_stat_frames ? s_stat_frames : 1);
  unsigned all = ticks_to_us(s_busy_ticks) / s_stat_runs;

  logbuf_printf("t=%u run %u.%u new %u.%u vbl %u emu %u.%u all %u.%u snd %u u %lu o %lu",
                ++s_stat_secs, runs10 / 10, runs10 % 10, new10 / 10, new10 % 10, vbl,
                emu / 1000, emu % 1000 / 100, all / 1000, all % 1000 / 100, snd,
                (unsigned long)s_snd_under, (unsigned long)s_snd_over);

  printf("\x1b[21;0Hrun %2u.%u new %2u.%u vbl %2u      ",
         runs10 / 10, runs10 % 10, new10 / 10, new10 % 10, vbl);
  printf("\x1b[22;0Hemu %2u.%ums all %2u.%ums         ",
         emu / 1000, emu % 1000 / 100, all / 1000, all % 1000 / 100);
  printf("\x1b[23;0Hsnd %5u/s u %lu o %lu      ", snd,
         (unsigned long)s_snd_under, (unsigned long)s_snd_over);
  {
    // The play position's own rate: it should equal the audio rate. When it
    // did not, the writer overran the play head once a frame.
    static uint16_t last_pos;
    uint16_t pos = audio_play_pos();
    unsigned prate = (unsigned)((uint64_t)(uint16_t)(pos - last_pos) * BUS_CLOCK / elapsed);

    last_pos = pos;
    printf("\x1b[20;0Hplay %5u/s ahead %u-%u      ", prate, s_ahead_min, s_ahead_max);
    logbuf_printf(" play %u ahead %u-%u", prate, s_ahead_min, s_ahead_max);
  }
  s_ahead_min = 0xFFFF;
  s_ahead_max = 0;
  if (s_prof[0] | s_prof[1] | s_prof[2] | s_prof[3]) {
    unsigned p[PROF_SLOTS];
    for (unsigned i = 0; i < PROF_SLOTS; i++) {
      p[i] = ticks_to_us(s_prof[i]) / s_stat_runs;
      s_prof[i] = 0;
    }
    // ms per frame: emulated CPU+video+sound generation, resampling, handing
    // audio to us, handing video to us.
    logbuf_printf(" cpu %u.%u rs %u.%u au %u.%u vi %u.%u",
                  p[0] / 1000, p[0] % 1000 / 100, p[1] / 1000, p[1] % 1000 / 100,
                  p[2] / 1000, p[2] % 1000 / 100, p[3] / 1000, p[3] % 1000 / 100);
    printf("\x1b[19;0Hcpu %2u.%u rs %2u.%u au %2u.%u vi %2u.%u  ",
           p[0] / 1000, p[0] % 1000 / 100, p[1] / 1000, p[1] % 1000 / 100,
           p[2] / 1000, p[2] % 1000 / 100, p[3] / 1000, p[3] % 1000 / 100);
  }

  logbuf_printf("\n");

  s_stat_start = now;
  s_stat_vblanks = s_vblanks;
  s_busy_ticks = s_emu_ticks = 0;
  s_stat_runs = s_stat_frames = 0;
  s_snd_in = 0;
}

void rd_plat_wait_frame(void) {
  stats_frame(cpuGetTiming() - s_frame_start);

  // Only wait if the vblank has not already gone by: a frame that ran long
  // then starts the next one at once instead of losing a whole extra frame.
  if (s_vblanks == s_vblank_seen)
    swiWaitForVBlank();
  s_vblank_seen = s_vblanks;

  if (s_flip) {
    bgSetMapBase(s_bg, s_back ? 8 : 0);
    s_back ^= 1;
    s_flip = false;
  }

  s_frame_start = cpuGetTiming();
}

void rd_plat_av_setup(unsigned max_width, unsigned max_height,
                      unsigned sample_rate) {
  video_setup(max_width);
  audio_setup(sample_rate);

  irqSet(IRQ_VBLANK, on_vblank);
  irqEnable(IRQ_VBLANK);
  cpuStartTiming(2);

  // Report the mode and an estimate of the ARM9 clock: the BIOS delay loop is
  // 4 cycles per iteration, so timing a known count gives MHz.
  {
    uint32_t t0 = cpuGetTiming();
    swiDelay(1000000);
    unsigned us = ticks_to_us(cpuGetTiming() - t0);
    printf("%s mode, ARM9 ~%u MHz\n", isDSiMode() ? "DSi" : "DS",
           us ? 4000000u / us : 0);
    logbuf_printf("%s, %s mode, ARM9 ~%u MHz, video max %ux%u, audio %u Hz\n",
                  RD_APP_NAME, isDSiMode() ? "DSi" : "DS",
                  us ? 4000000u / us : 0, max_width, max_height, sample_rate);
  }
  s_stat_start = s_frame_start = cpuGetTiming();
}

void rd_plat_stats_begin(const char* label) {
  logbuf_printf("== %s\n", label);
  s_stat_secs = 0;
  s_snd_under = s_snd_over = 0;
}

void rd_plat_stats_flush(const char* path) {
  FILE* f;

  if (!s_loglen)
    return;
  f = fopen(path, "ab");
  if (f) {
    fwrite(s_logbuf, 1, s_loglen, f);
    fclose(f);
  }
  s_loglen = 0;
}

// --- input -------------------------------------------------------------------

static bool s_quit;
static bool s_joy[16];

// Indexed by RETRO_DEVICE_ID_JOYPAD_*.
static const uint16_t s_keymap[16] = {
    KEY_B,
    KEY_Y,
    KEY_SELECT,
    KEY_START,
    KEY_UP,
    KEY_DOWN,
    KEY_LEFT,
    KEY_RIGHT,
    KEY_A,
    KEY_X,
    KEY_L,
    KEY_R,
    0,
    0,
    0,
    0,
};

void rd_plat_poll_input(void) {
  // keysHeld() only reports what the last scanKeys() saw.
  scanKeys();

  uint16_t keys = keysHeld();

  for (unsigned i = 0; i < 16; i++)
    s_joy[i] = s_keymap[i] && (keys & s_keymap[i]);

  if ((keys & (KEY_L | KEY_R | KEY_START | KEY_SELECT)) ==
      (KEY_L | KEY_R | KEY_START | KEY_SELECT))
    s_quit = true;
}

bool rd_plat_button(unsigned id) {
  return id < 16 ? s_joy[id] : false;
}

bool rd_plat_quit_requested(void) {
  return s_quit;
}

// --- system ------------------------------------------------------------------

// picolibc on the DS has no kernel sleep, but libretro-common's retro_timers.h
// calls nanosleep(). Busy-wait instead; frames are paced by vblank, not by this.
int nanosleep(const struct timespec* req, struct timespec* rem) {
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
    swiDelay(step * 12);  // ~12 ARM9 cycles per microsecond (67/133 MHz)
    us -= step;
  }
  return 0;
}

bool rd_plat_init(void) {
  // DSi mode: run the ARM9 at 133 MHz rather than the DS's 67.
  if (isDSiMode())
    setCpuClock(true);

  // The console comes up first, so a failure below is visible on the bottom
  // screen instead of leaving both black. The top screen stays black (no
  // background enabled) until rd_plat_av_setup().
  videoSetMode(MODE_5_2D);
  setBackdropColor(RGB15(0, 0, 0));
  consoleDemoInit();

  soundEnable();

  // The ROMs and apps are on the flashcart's card ("fat:", through the DLDI
  // driver Pico Loader patches in). In DSi mode fatInitDefault() also mounts
  // the console's own SD slot ("sd:"), makes that the default, and returns
  // false when that slot is empty, even if "fat:" mounted fine. So check
  // "fat:" directly, and make it the default so relative and launcher-style
  // "/roms/..." paths land on the flashcart.
  bool any = fatInitDefault();
  DIR* d = opendir("fat:/");

  if (d) {
    closedir(d);
    chdir("fat:/");
    return true;
  }
  return any;
}

void rd_plat_deinit(void) {
  soundKill(SND_CH_L);
  soundKill(SND_CH_R);
  TIMER_CR(0) = 0;
  TIMER_CR(1) = 0;
  soundDisable();
}

// Firmware and saves live next to the .nds, so one directory on the SD card is
// the whole deployment:
//
//     apps/retrods-quicknes.nds
//     apps/bios/o2rom.bin
//     apps/saves/
//
#define RD_PATH_MAX 512
static char s_base_dir[RD_PATH_MAX] = "fat:";
static char s_system_dir[RD_PATH_MAX] = "fat:/bios";
static char s_save_dir[RD_PATH_MAX] = "fat:/saves";

void rd_plat_set_program_path(const char* argv0) {
  const char* slash;
  size_t len;
  char tmp[RD_PATH_MAX];

  if (argv0 != NULL && (slash = strrchr(argv0, '/')) != NULL && slash != argv0) {
    len = (size_t)(slash - argv0);
    if (len < sizeof(tmp)) {
      snprintf(tmp, sizeof(tmp), "%.*s", (int)len, argv0);
      // Pico Launcher passes "fat:/apps/..."; a bare "/apps/..." still needs
      // the device prefix libfat expects.
      if (tmp[0] == '/' && strchr(tmp, ':') == NULL)
        snprintf(s_base_dir, sizeof(s_base_dir), "fat:%s", tmp);
      else
        snprintf(s_base_dir, sizeof(s_base_dir), "%s", tmp);
    }
  }

  snprintf(s_system_dir, sizeof(s_system_dir), "%s/bios", s_base_dir);
  snprintf(s_save_dir, sizeof(s_save_dir), "%s/saves", s_base_dir);
}

const char* rd_plat_system_dir(void) {
  return s_system_dir;
}

const char* rd_plat_save_dir(void) {
  return s_save_dir;
}

void rd_plat_hold(const char* msg) {
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

void rd_plat_log(const char* s) {
  printf("%s\n", s);
}

void rd_plat_status(const char* s) {
  printf("\x1b[0;0H%s\n", s);
}

// Screenshots go out as 24-bit BMP: the DS has no image encoder, and a BMP
// needs none. Rows are bottom-up and padded to four bytes, as BMP requires.
void rd_plat_screenshot(const void* data, unsigned width, unsigned height,
                        size_t pitch, enum rd_pixel_format fmt,
                        const char* base_path) {
  char path[256];
  unsigned bpp = (fmt == RD_PIXEL_XRGB8888) ? 4 : 2;
  unsigned row_bytes = (width * 3 + 3) & ~3u;
  uint32_t file_size = 54 + row_bytes * height;
  uint8_t header[54];
  FILE* f;

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
  *(uint32_t*)(header + 10) = 54;
  *(uint32_t*)(header + 14) = 40;
  *(int32_t*)(header + 18) = (int32_t)width;
  *(int32_t*)(header + 22) = (int32_t)height;
  *(uint16_t*)(header + 26) = 1;
  *(uint16_t*)(header + 28) = 24;
  *(uint32_t*)(header + 34) = row_bytes * height;
  fwrite(header, 1, sizeof(header), f);

  for (unsigned y = 0; y < height; y++) {
    const uint8_t* row = (const uint8_t*)data + (size_t)(height - 1 - y) * pitch;
    uint8_t pad[3] = {0, 0, 0};
    unsigned written = 0;

    for (unsigned x = 0; x < width; x++) {
      uint16_t c = convert(row + (size_t)x * bpp, fmt);
      uint8_t bgr[3];

      bgr[0] = (uint8_t)(((c >> 10) & 0x1F) * 255 / 31);
      bgr[1] = (uint8_t)(((c >> 5) & 0x1F) * 255 / 31);
      bgr[2] = (uint8_t)((c & 0x1F) * 255 / 31);
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

// --- files -------------------------------------------------------------------

void* rd_plat_read_file(const char* path, size_t* size_out) {
  FILE* f = fopen(path, "rb");
  long size;
  void* buf;

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

bool rd_plat_write_file(const char* path, const void* data, size_t size) {
  FILE* f = fopen(path, "wb");
  bool ok;

  if (!f)
    return false;

  ok = fwrite(data, 1, size, f) == size;
  fclose(f);

  return ok;
}

bool rd_plat_file_exists(const char* path) {
  FILE* f = fopen(path, "rb");

  if (!f)
    return false;

  fclose(f);
  return true;
}
