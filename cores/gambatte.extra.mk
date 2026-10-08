# Netplay needs BSD sockets, which the DS does not have. The core guards its
# serial-link code with HAVE_NETWORK, so build without it and drop the socket
# implementation; patches/gambatte-libretro/ guards the one reference that was
# outside the #ifdef.
gambatte_DEFINES := $(filter-out -DHAVE_NETWORK,$(gambatte_DEFINES))
gambatte_SRCS := $(filter-out %net_serial.cpp,$(gambatte_SRCS))
gambatte_CXX_SRCS := $(filter-out %net_serial.cpp,$(gambatte_CXX_SRCS))

gambatte_EXTS := gb gbc dmg

# retrods: add dmg: the core declares it.

# DS only: render in the console's native pixel format (patches/gambatte-libretro
# 0002), so the frontend can DMA the frame instead of converting every pixel,
# and generate audio at the output rate instead of ~2 MHz (0003).
gambatte_NDS_DROP := -DVIDEO_RGB565
gambatte_NDS_DEFINES := -DVIDEO_ABGR1555 -DVIDEO_ABGR1555_OPAQUE -DGAMBATTE_DECIMATED_PSG
gambatte_NDS_NATIVE_PIXELS := 1
