# ti99sim's own build sets -fexceptions: its LZW decoder uses try/catch, and
# without it the whole block is skipped and retVal never gets declared.
ti99_CXXFLAGS := -fexceptions
