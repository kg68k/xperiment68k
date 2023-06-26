# Makefile for Xperiment68k

ifeq ($(notdir $(CURDIR)),src)
$(error do not execute make in src directory)
endif

CC	= gcc2
CFLAGS	= -Wall -O2
AS	= has
HAS060	= has060
ASFLAGS	= -w
LD	= hlk
LD_R	= $(LD) -r
LDFLAGS	=
MKDIR_P	= mkdir -p

OBJ_DIR = o


.PHONY: all directories clean
.PRECIOUS: $(OBJ_DIR)/%.o


TARGET = a2arg.x adpcmotchk.x bitsns.x chxdummy.x colorbar.x con_scroll.x dbrams.x \
         dos_create_sp.x dos_fatchk.x dos_keyctrl01.x dos_nameck.x dos_open.x \
         esc_dsr.x fatchk_bof.x fntget.x fntsize.x has060c4.x \
         iocs_txfill.x iocs_txyline.x iocs_txrascpy.x \
         joyget.x keepceil.x keyflush.x mallocall.x midi_reg.x \
         pt_7e.x pt_dbhw.x putmes12.x putmes24.x reset68k.r \
         si_acc.x si_emu.x si_memory.x si_midi.x si_model.x si_phantomx.x si_scsiex.x si_sram.x \
         sjis_tbl.x sp3tx0gr2.x splimchk.x sq64k.x sysport.x

all: directories $(TARGET)

directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/has060c4.o: has060c4.s
	$(HAS060) $(ASFLAGS) -y -c4 -o $@ $<

$(OBJ_DIR)/%.o: %.s $(OBJ_DIR) include/xputil.mac
	$(AS) $(ASFLAGS) -o $@ $<

# cancel default rule
%.x: %.s

keepceil.x: $(OBJ_DIR)/keepceil.o
	$(LD) $(LDFLAGS) -g2 -o $@ $^

sjis_tbl.x: sjis_tbl.c
	$(CC) $(CFLAGS) -o $@ $^

%.x: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^

%.r: $(OBJ_DIR)/%.o
	$(LD_R) $(LDFLAGS) -o $@ $^


clean:
	-rm -f $(TARGET) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
