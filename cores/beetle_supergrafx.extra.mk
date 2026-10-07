# Some of the mednafen-based C++ code uses exceptions, and GCC 14 rejects a
# few incompatible-pointer-types conversions in mednafen's tremor by default.
beetle_supergrafx_CXXFLAGS := -fexceptions -Wno-incompatible-pointer-types
beetle_supergrafx_CFLAGS := -Wno-incompatible-pointer-types

beetle_supergrafx_EXTS := pce sgx

# retrods: add pce, as the core declares; pce_fast still wins .pce in a multi-core build.
