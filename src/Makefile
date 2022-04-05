# Makefile for Xperiment68k

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
BUSERR = $(OBJ_DIR)/dosbuserr.o


.PHONY: all directories clean
.PRECIOUS: $(OBJ_DIR)/%.o


TARGET = chxdummy.x dbrams.x mallocall.x midi_reg.x \
         si_acc.x si_emu.x si_midi.x si_model.x si_phantomx.x si_scsiex.x si_sram.x

all: directories $(TARGET)

chxdummy.x:    $(OBJ_DIR)/chxdummy.o
dbrams.x:      $(OBJ_DIR)/dbrams.o
mallocall.x:   $(OBJ_DIR)/mallocall.o
midi_reg.x:    $(OBJ_DIR)/midi_reg.o
si_acc.x:      $(OBJ_DIR)/si_acc.o    $(BUSERR)
si_emu.x:      $(OBJ_DIR)/si_emu.o    $(BUSERR)
si_midi.x:     $(OBJ_DIR)/si_midi.o   $(BUSERR)
si_model.x:    $(OBJ_DIR)/si_model.o  $(BUSERR)
si_phantomx.x: $(OBJ_DIR)/si_phantomx.o $(BUSERR)
si_scsiex.x:   $(OBJ_DIR)/si_scsiex.o $(BUSERR)
si_sram.x:     $(OBJ_DIR)/si_sram.o   $(BUSERR)


directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/%.o: %.s $(OBJ_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

%.x:
	$(LD) $(LDFLAGS) -o $@ $^


clean:
	-rm -f $(TARGET) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
