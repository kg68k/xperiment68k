# Makefile for Xperiment68k

ifeq ($(notdir $(CURDIR)),src)
$(error do not execute make in src directory)
endif

CC	= gcc2
CFLAGS	= -Wall -O2
AS	= has
ASFLAGS	= -w
LD	= hlk
LD_R	= $(LD) -r
LDFLAGS	=
MKDIR_P	= mkdir -p

OBJ_DIR = o


.PHONY: all directories clean
.PRECIOUS: $(OBJ_DIR)/%.o


TARGET = a2arg.x chxdummy.x colorbar.x dbrams.x \
         dos_create_sp.x dos_fatchk.x dos_keyctrl01.x dos_nameck.x dos_open.x \
         esc_dsr.x fatchk_bof.x joyget.x keepceil.x keyflush.x \
         mallocall.x midi_reg.x pt_dbhw.x putmes24.x \
         si_acc.x si_emu.x si_memory.x si_midi.x si_model.x si_phantomx.x si_scsiex.x si_sram.x \
         sjis_tbl.x splimchk.x sq64k.x sysport.x

all: directories $(TARGET)

directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/%.o: %.s $(OBJ_DIR) include/xputil.mac
	$(AS) $(ASFLAGS) -o $@ $<

# cancel default rule
%.x: %.s

keepceil.x: $(OBJ_DIR)/keepceil.o
	$(LD) $(LDFLAGS) -g2 -o $@ $^

%.x: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^

sjis_tbl.x: sjis_tbl.c
	$(CC) $(CFLAGS) -o $@ $^


clean:
	-rm -f $(TARGET) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
