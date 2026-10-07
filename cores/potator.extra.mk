# The generated file puts _DIR at platform/libretro, which is where the libretro
# Makefile lives, but Potator's emulation sources are in common/ as well.
# core_rules.mk derives object paths from _DIR, so point it at the repository
# root and every source maps to an object under build/<target>/core/potator/.
potator_DIR := third_party/Potator
