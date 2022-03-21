# Makefile for Xperiment68k/si_scsiex test

ifeq ($(notdir $(CURDIR)),src)
$(error do not execute make in src directory)
endif

AS	= has
ASFLAGS	= -w -i include
LD	= hlk
LD_R	= $(LD) -r
LDFLAGS	=
MKDIR_P	= mkdir -p

OBJ_DIR = o
BUSERR = $(OBJ_DIR)/dosbusfake.o


.PHONY: all directories clean
.PRECIOUS: $(OBJ_DIR)/%.o


TARGET = si_scsiex0.x si_scsiex1.x si_scsiex2.x si_scsiex3.x si_scsiex4.x \
	 si_scsiex8.x si_scsiex9.x si_scsiex10.x si_scsiex11.x si_scsiex12.x \
	 si_scsiex13.x

all: directories $(TARGET)


directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/dosbusfake.o: dosbusfake.s
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_DIR)/si_scsiex%.o: si_scsiex.s  si_scsiex_test.mac
	$(AS) $(ASFLAGS) -sTEST=$* -o $@ $<

si_scsiex%.x: $(OBJ_DIR)/si_scsiex%.o $(BUSERR)
	$(LD) $(LDFLAGS) -o $@ $^


clean:
	-rm -f $(EXES) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
