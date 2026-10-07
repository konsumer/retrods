# Netplay needs BSD sockets, which the DS does not have. The core guards its
# serial-link code with HAVE_NETWORK, so build without it and drop the socket
# implementation; patches/gambatte-libretro/ guards the one reference that was
# outside the #ifdef.
gambatte_DEFINES := $(filter-out -DHAVE_NETWORK,$(gambatte_DEFINES))
gambatte_SRCS := $(filter-out %net_serial.cpp,$(gambatte_SRCS))
gambatte_CXX_SRCS := $(filter-out %net_serial.cpp,$(gambatte_CXX_SRCS))

gambatte_EXTS := gb gbc dmg

# retrods: add dmg: the core declares it.
