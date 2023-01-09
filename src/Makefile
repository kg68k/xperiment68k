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


TARGET = a2arg.x chxdummy.x colorbar.x dbrams.x \
         dos_create_sp.x dos_keyctrl01.x dos_nameck.x dos_open.x \
         esc_dsr.x keyflush.x mallocall.x midi_reg.x pt_dbhw.x putmes24.x \
         si_acc.x si_emu.x si_memory.x si_midi.x si_model.x si_phantomx.x si_scsiex.x si_sram.x \
         sjis_tbl.x sq64k.x sysport.x

all: directories $(TARGET)

si_acc.x:        $(OBJ_DIR)/si_acc.o    $(BUSERR)
si_emu.x:        $(OBJ_DIR)/si_emu.o    $(BUSERR)
si_memory.x:     $(OBJ_DIR)/si_memory.o $(BUSERR)
si_midi.x:       $(OBJ_DIR)/si_midi.o   $(BUSERR)
si_model.x:      $(OBJ_DIR)/si_model.o  $(BUSERR)
si_phantomx.x:   $(OBJ_DIR)/si_phantomx.o $(BUSERR)
si_scsiex.x:     $(OBJ_DIR)/si_scsiex.o $(BUSERR)
si_sram.x:       $(OBJ_DIR)/si_sram.o   $(BUSERR)
sysport.x:       $(OBJ_DIR)/sysport.o   $(BUSERR)


directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/%.o: %.s $(OBJ_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

# cancel default rule
%.x: %.s

%.x: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^

sjis_tbl.x: sjis_tbl.c
	$(CC) $(CFLAGS) -o $@ $^


clean:
	-rm -f $(TARGET) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
