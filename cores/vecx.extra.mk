# vecx's optional OpenGL path pulls in libretro-common/glsym, which needs GL
# headers; the libretro port renders in software on this target.
#
# (make's filter-out only treats the first % as special, hence findstring)
vecx_DEFINES := $(filter-out -DHAS_GPU,$(vecx_DEFINES))
vecx_SRCS := $(foreach f,$(vecx_SRCS),$(if $(findstring libretro-common/glsym/,$(f)),,$(f)))
vecx_CXX_SRCS := $(foreach f,$(vecx_CXX_SRCS),$(if $(findstring libretro-common/glsym/,$(f)),,$(f)))
