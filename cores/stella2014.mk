# SPDX-License-Identifier: Zlib
#
# Generated from third_party/stella2014-libretro/Makefile by scripts/gen-core-mk.py.
# Edit the generator, not this file, then re-run it.

stella2014_DIR := third_party/stella2014-libretro
stella2014_EXTS := a26

stella2014_SRCS := \
    third_party/stella2014-libretro/stella/src/emucore/Thumbulator.c \
    third_party/stella2014-libretro/libretro-common/compat/compat_posix_string.c \
    third_party/stella2014-libretro/libretro-common/compat/compat_strcasestr.c \
    third_party/stella2014-libretro/libretro-common/compat/compat_snprintf.c \
    third_party/stella2014-libretro/libretro-common/compat/compat_strl.c \
    third_party/stella2014-libretro/libretro-common/compat/fopen_utf8.c \
    third_party/stella2014-libretro/libretro-common/encodings/encoding_utf.c \
    third_party/stella2014-libretro/libretro-common/file/file_path.c \
    third_party/stella2014-libretro/libretro-common/file/file_path_io.c \
    third_party/stella2014-libretro/libretro-common/time/rtime.c \
    third_party/stella2014-libretro/libretro-common/streams/file_stream.c \
    third_party/stella2014-libretro/libretro-common/streams/file_stream_transforms.c \
    third_party/stella2014-libretro/libretro-common/string/stdstring.c \
    third_party/stella2014-libretro/libretro-common/vfs/vfs_implementation.c

stella2014_CXX_SRCS := \
    third_party/stella2014-libretro/stella/src/common/Base.cxx \
    third_party/stella2014-libretro/stella/src/common/Sound.cxx \
    third_party/stella2014-libretro/stella/src/emucore/AtariVox.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Booster.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartARM.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart0840.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart0FA0.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart03E0.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartWD.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart2K.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart3E.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart3EX.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart3EPlus.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart3F.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart4A50.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart4K.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Cart4KSC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartAR.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartBF.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartBFSC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartBUS.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartCDF.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartCM.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartCTY.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartCV.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartDF.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartDFSC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartDPC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartDPCPlus.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartE0.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartE7.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartEF.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartEnhanced.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartEFSC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartF0.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartF4.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartF4SC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartF6.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartF6SC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartF8.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartF8SC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartFA.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartFA2.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartFC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartFE.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartGL.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartMC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartMDM.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartMVC.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartSB.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartTVBoy.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartUA.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CartX07.cxx \
    third_party/stella2014-libretro/stella/src/emucore/CompuMate.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Console.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Control.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Driving.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Genesis.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Joystick.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Keyboard.cxx \
    third_party/stella2014-libretro/stella/src/emucore/KidVid.cxx \
    third_party/stella2014-libretro/stella/src/emucore/M6502.cxx \
    third_party/stella2014-libretro/stella/src/emucore/M6532.cxx \
    third_party/stella2014-libretro/stella/src/emucore/MD5.cxx \
    third_party/stella2014-libretro/stella/src/emucore/MindLink.cxx \
    third_party/stella2014-libretro/stella/src/emucore/MT24LC256.cxx \
    third_party/stella2014-libretro/stella/src/emucore/NullDev.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Paddles.cxx \
    third_party/stella2014-libretro/stella/src/emucore/QuadTari.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Props.cxx \
    third_party/stella2014-libretro/stella/src/emucore/PropsSet.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Random.cxx \
    third_party/stella2014-libretro/stella/src/emucore/SaveKey.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Serializer.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Settings.cxx \
    third_party/stella2014-libretro/stella/src/emucore/StateManager.cxx \
    third_party/stella2014-libretro/stella/src/emucore/Switches.cxx \
    third_party/stella2014-libretro/stella/src/emucore/System.cxx \
    third_party/stella2014-libretro/stella/src/emucore/TIA.cxx \
    third_party/stella2014-libretro/stella/src/emucore/TIASnd.cxx \
    third_party/stella2014-libretro/stella/src/emucore/TIATables.cxx \
    third_party/stella2014-libretro/stella/src/emucore/TrackBall.cxx \
    third_party/stella2014-libretro/libretro.cxx

stella2014_DEFINES := \
    -DNDEBUG -D__LIBRETRO__

stella2014_INCLUDES := \
    -Ithird_party/stella2014-libretro \
    -Ithird_party/stella2014-libretro/stella \
    -Ithird_party/stella2014-libretro/stella/src \
    -Ithird_party/stella2014-libretro/stella/stubs \
    -Ithird_party/stella2014-libretro/stella/src/emucore \
    -Ithird_party/stella2014-libretro/stella/src/common \
    -Ithird_party/stella2014-libretro/stella/src/gui \
    -Ithird_party/stella2014-libretro/libretro-common/include

