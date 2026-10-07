# MSX.h defines INLINE as `static inline`, which collides with libretro-common's
# headers (strl.h writes `static INLINE ...`, so it becomes `static static`).
# Defining INLINE for the command line makes MSX.h keep its hands off, and GNU
# inline semantics keep fmsx's own inline functions emitted.
fmsx_CFLAGS := -DINLINE=__inline__ -fgnu89-inline

fmsx_EXTS := rom mx1 mx2 dsk fdi cas

# retrods: add fdi: MSX floppy images.
