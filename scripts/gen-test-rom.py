#!/usr/bin/env python3
# SPDX-License-Identifier: Zlib
#
# Generate trivial homebrew ROM images for the host harness, so every core can
# be smoke-tested without copyrighted content. The system is chosen from the
# output file's extension.
#
#   python3 scripts/gen-test-rom.py build-host/out/test.sms
#   python3 scripts/gen-test-rom.py build-host/out/test.gb
#
# Each image parks the CPU in an infinite loop and leaves the video hardware in
# its power-on state, which is enough for a core to produce frames.

import sys

NINTENDO_LOGO = bytes([
    0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83,
    0x00, 0x0C, 0x00, 0x0D, 0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E,
    0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99, 0xBB, 0xBB, 0x67, 0x63,
    0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E,
])


def gen_sms():
    """Sega Master System: 32 KiB, valid `TMR SEGA` header, Z80 in `jr $`."""
    size = 0x8000
    rom = bytearray(size)
    rom[0x00] = 0xF3          # di
    rom[0x01] = 0x18          # jr
    rom[0x02] = 0xFD          # -3
    rom[0x7FF0:0x7FF8] = b"TMR SEGA"
    checksum = sum(rom[:0x7FF0]) & 0xFFFF
    rom[0x7FFA] = checksum & 0xFF
    rom[0x7FFB] = (checksum >> 8) & 0xFF
    rom[0x7FFF] = 0x4C        # SMS export, no version
    return rom


def gen_gb():
    """Game Boy: 32 KiB ROM-only cartridge, LR35902 in `jr $`."""
    size = 0x8000
    rom = bytearray(size)
    rom[0x0100] = 0x00                  # nop
    rom[0x0101:0x0104] = b"\xC3\x50\x01"  # jp 0x0150
    rom[0x0150] = 0x18                  # jr
    rom[0x0151] = 0xFE                  # -2
    rom[0x0104:0x0104 + 48] = NINTENDO_LOGO
    rom[0x0134:0x013E] = b"RETRODS" + b"\x00" * 5
    rom[0x0143] = 0x00                  # not CGB-only
    rom[0x0147] = 0x00                  # ROM only
    rom[0x0148] = 0x00                  # 32 KiB
    rom[0x0149] = 0x00                  # no RAM
    rom[0x014C] = 0x00                  # version
    header_check = 0
    for b in rom[0x0134:0x014D]:
        header_check = (header_check - b - 1) & 0xFF
    rom[0x014D] = header_check
    total = sum(rom) & 0xFFFF
    rom[0x014E] = (total >> 8) & 0xFF
    rom[0x014F] = total & 0xFF
    return rom


def gen_snes():
    """SNES: 32 KiB LoROM image, 65816 in `bra $`, valid internal header."""
    size = 0x8000
    rom = bytearray(size)
    rom[0x0000] = 0x80        # bra
    rom[0x0001] = 0xFE        # -2
    h = 0x7FC0
    rom[h:h + 21] = b"RETRODS".ljust(21, b"\x00")
    rom[h + 0x15] = 0x20      # LoROM, slow
    rom[h + 0x16] = 0x00      # ROM only
    rom[h + 0x17] = 0x05      # 32 KiB (log2(KiB) - 10)
    rom[h + 0x18] = 0x00      # no SRAM
    rom[h + 0x19] = 0x01      # NTSC
    rom[h + 0x1A] = 0x33      # developer id
    rom[h + 0x1B] = 0x00      # version
    rom[0x7FFC:0x7FFE] = b"\x00\x80"   # reset vector -> $8000
    rom[0x7FFA:0x7FFC] = b"\x00\x80"   # NMI
    rom[0x7FFE:0x8000] = b"\x00\x80"   # IRQ
    # checksum: 16-bit sum of the whole image with the checksum bytes zeroed
    rom[h + 0x1C] = 0x00
    rom[h + 0x1D] = 0x00
    rom[h + 0x1E] = 0xFF
    rom[h + 0x1F] = 0xFF
    checksum = sum(rom) & 0xFFFF
    rom[h + 0x1C] = (checksum ^ 0xFFFF) & 0xFF
    rom[h + 0x1D] = ((checksum ^ 0xFFFF) >> 8) & 0xFF
    rom[h + 0x1E] = checksum & 0xFF
    rom[h + 0x1F] = checksum >> 8
    return rom


def gen_nes():
    """NES: NROM (mapper 0), 16 KiB PRG + 8 KiB CHR, 6502 in `jmp $8000`."""
    header = b"NES\x1a" + bytes([1, 1, 0, 0]) + bytes(8)
    prg = bytearray(0x4000)
    prg[0x0000] = 0x4C        # jmp $8000
    prg[0x0001] = 0x00
    prg[0x0002] = 0x80
    prg[0x3FFC] = 0x00        # reset vector -> $8000
    prg[0x3FFD] = 0x80
    return header + bytes(prg) + bytes(0x2000)


def gen_gba():
    """GBA: minimal ROM header + ARM `b .` at the entry point.

    Note a real GBA BIOS dump (gba_bios.bin in the system directory) is needed
    for either GBA core to actually emulate.
    """
    rom = bytearray(0x8000)
    rom[0x00:0x04] = b"\x2E\x00\x00\xEA"   # b 0x080000C0
    rom[0xA0:0xA0 + 9] = b"RETRODS\x00\x00"
    rom[0xB0:0xB2] = b"01"                 # maker
    rom[0xB2] = 0x96                       # 96h marker
    rom[0xC0:0xC4] = b"\xFE\xFF\xFF\xEA"   # b .
    chk = 0
    for b in rom[0xA0:0xBD]:
        chk -= b
    rom[0xBD] = (chk - 0x19) & 0xFF
    return rom


def gen_chf():
    """Fairchild Channel F: 2 KiB cartridge image (F8 runs from $800)."""
    rom = bytearray(0x0800)
    rom[0x000] = 0x00        # nop
    rom[0x001] = 0x00
    return rom


def gen_vec():
    """Vectrex: 8 KiB cartridge, 6809 in `bra $`."""
    rom = bytearray(0x2000)
    rom[0x0000] = 0x20        # bra
    rom[0x0001] = 0xFE        # -2
    rom[0x1FFE] = 0x00        # reset vector -> 0x0000
    rom[0x1FFF] = 0x00
    return rom


def gen_vb():
    """Virtual Boy: minimal 1 MiB ROM image with a plausible header."""
    size = 0x100000
    rom = bytearray(size)
    # Every slice assignment must be exactly as wide as the range it replaces,
    # or the bytearray changes length (the Virtual Boy loader requires a
    # power-of-two ROM).
    rom[0x000:0x005] = b"RETRO"
    rom[0x005:0x00C] = b"VUE".ljust(7, b"\x00")
    rom[0x020:0x022] = b"rd"
    rom[0x022:0x02A] = b"RETRODS ".ljust(8, b"\x00")
    rom[0x02A:0x02B] = b"\x00"
    assert len(rom) == size, len(rom)
    return rom


def gen_o2():
    """Odyssey2: 2 KiB cartridge (the 8048 resets to address 0, NOPs are fine)."""
    return bytearray(0x800)


def gen_sna():
    """ZX Spectrum: a 48K .sna snapshot (27-byte header + 48 KiB of RAM).

    A .sna has no PC field -- the PC is popped off the stack -- so the header
    points SP into RAM and the reset vector is written there, which makes the
    Spectrum ROM boot to its BASIC screen like a real power-on.
    """
    RAM = 0xC000                      # 0x4000-0xFFFF
    sp = 0x5000
    ram = bytearray(RAM)
    ram[sp - 0x4000:sp - 0x4000 + 2] = b"\x00\x00"   # PC = 0x0000, the ROM reset

    h = bytearray(27)
    h[0] = 0x3F                       # I
    h[19] = 0                         # IFF2
    h[20] = 0                         # R
    h[21:23] = (0x0000).to_bytes(2, "little")   # AF
    h[23:25] = sp.to_bytes(2, "little")          # SP
    h[25] = 1                         # interrupt mode
    h[26] = 7                         # border: white, like a fresh Spectrum
    return bytes(h) + bytes(ram)


GENERATORS = {
    "sms": gen_sms,
    "gb": gen_gb,
    "gbc": gen_gb,
    "nes": gen_nes,
    "gba": gen_gba,
    "chf": gen_chf,
    "o2": gen_o2,
    "sna": gen_sna,
    "vec": gen_vec,
    "vb": gen_vb,
    "vboy": gen_vb,
    "sfc": gen_snes,
    "smc": gen_snes,
}


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "build-host/out/test.sms"
    ext = path.rsplit(".", 1)[-1].lower()
    gen = GENERATORS.get(ext)
    if gen is None:
        print(f"no generator for .{ext} (have: {', '.join(sorted(GENERATORS))})",
              file=sys.stderr)
        return 2
    rom = gen()
    with open(path, "wb") as f:
        f.write(rom)
    print(f"wrote {path} ({len(rom)} bytes, {ext})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
