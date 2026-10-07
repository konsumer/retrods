# GCC 14 rejects this incompatible-pointer-types initialisation by default
# (uint32_t is a distinct type from unsigned int on ARMv5TE).
cap32_CFLAGS := -Wno-incompatible-pointer-types -Wno-int-conversion

# The generated list omitted .dsk, the usual extension for Amstrad CPC disk
# images, so those files were being opened by fmsx -- which also claims .dsk for
# MSX disks. Both cores now claim it; which one wins for a given build depends
# on the order in CORES, and for Pico Launcher associations on
# scripts/gen-settings.py's preference table.
cap32_EXTS := dsk cpc tap sna

# retrods: drop .d64/.t64: those are Commodore formats, not Amstrad.
