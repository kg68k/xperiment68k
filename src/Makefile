# Makefile for Xperiment68k

ifeq ($(notdir $(CURDIR)),src)
$(error do not execute make in src directory)
endif

CC	= gcc2
CFLAGS	= -Wall -O2
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


TARGET = chxdummy.x dbrams.x dos_create_sp.x dos_nameck.x dos_open.x esc_dsr.x \
         mallocall.x midi_reg.x pt_dbhw.x \
         si_acc.x si_emu.x si_midi.x si_model.x si_phantomx.x si_scsiex.x si_sram.x \
         sjis_tbl.x

all: directories $(TARGET)

chxdummy.x:      $(OBJ_DIR)/chxdummy.o
dbrams.x:        $(OBJ_DIR)/dbrams.o
dos_create_sp.x: $(OBJ_DIR)/dos_create_sp.o
dos_open.x:      $(OBJ_DIR)/dos_open.o
dos_nameck.x:    $(OBJ_DIR)/dos_nameck.o
esc_dsr.x:       $(OBJ_DIR)/esc_dsr.o
mallocall.x:     $(OBJ_DIR)/mallocall.o
midi_reg.x:      $(OBJ_DIR)/midi_reg.o
pt_dbhw.x:       $(OBJ_DIR)/pt_dbhw.o
si_acc.x:        $(OBJ_DIR)/si_acc.o    $(BUSERR)
si_emu.x:        $(OBJ_DIR)/si_emu.o    $(BUSERR)
si_midi.x:       $(OBJ_DIR)/si_midi.o   $(BUSERR)
si_model.x:      $(OBJ_DIR)/si_model.o  $(BUSERR)
si_phantomx.x:   $(OBJ_DIR)/si_phantomx.o $(BUSERR)
si_scsiex.x:     $(OBJ_DIR)/si_scsiex.o $(BUSERR)
si_sram.x:       $(OBJ_DIR)/si_sram.o   $(BUSERR)


directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/%.o: %.s $(OBJ_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

%.x:
	$(LD) $(LDFLAGS) -o $@ $^

sjis_tbl.x: sjis_tbl.c
	$(CC) $(CFLAGS) -o $@ $^


clean:
	-rm -f $(TARGET) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
