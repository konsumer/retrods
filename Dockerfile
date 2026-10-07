# SPDX-License-Identifier: Zlib
#
# Build environment for retrods. BlocksDS is the modern DS SDK (GCC based,
# picolibc, FatFs) and matches the toolchain the DSpico / Pico Launcher
# projects themselves use.

FROM skylyrac/blocksds:slim-latest

# git + python3 are needed to fetch cores and generate test assets. bison is for
# the cores whose upstream makefiles generate a parser (fuse's debugger grammar);
# those generated sources are inputs to the build, not something we can skip.
RUN apt-get update \
 && apt-get install -y --no-install-recommends git make python3 ca-certificates \
     build-essential bison flex autoconf automake pkg-config autoconf-archive \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
