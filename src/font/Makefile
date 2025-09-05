# Makefile for Xperiment68k (font)

TARGET = \
         defchr_7621.x defchr_81f8.x exchr_hex.x fntget.x fntsize.x \
         uskcg24.x uskfontadr.x uskhw_hex.x

include ../common.mk

uskfontadr.x: $(OBJ_DIR)/uskfontadr.o
	$(LD) $(LDFLAGS) -b0x6800 -o $@ $^

# EOF
