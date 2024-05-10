# Makefile for Xperiment68k

ifeq ($(notdir $(CURDIR)),src)
$(error do not execute make in src directory)
endif

ifndef LD
LD = hlk
endif
ifeq ($(findstring hlkx,$(LD)),hlkx)
USE_HLKX = true
endif

CC	= gcc2
CFLAGS	= -Wall -O2
AS	= has060
ASFLAGS	= -w -i./include
LDFLAGS	=
MKDIR_P	= mkdir -p

OBJ_DIR = o


.PHONY: all directories clean
.PRECIOUS: $(OBJ_DIR)/%.o


ALLTARGET = \
         a2arg.x a2arg_nh.x adpcmotchk.x \
         beep_adpcmout.x beep_mpcm.x beep_zmsc3.x bitsns.x buserr_2w.x \
         chxdummy.x colorbar.x con_scroll.x \
         datetime.x dbrams.x defchr_869f.x \
         dos_create.x dos_create_sp.x dos_curdir.x \
         dos_fatchk.x dos_fgetc.x dos_fgets.x dos_filedate.x \
         dos_getenv.x dos_inpout.x \
         dos_keyctrl01.x dos_maketmp.x dos_nameck.x dos_namests.x dos_newfile.x dos_open.x \
         dumpenv.x dumpstdin.x \
         entryceil.x env_sbo.x esc_dsr.x execas.x fatchk_bof.x \
         fe_fcvt_test.x fe_stoh_test.x \
         files.x fntget.x fntsize.x \
         getassign.x \
         incdir_test.x iocs_ontime.x iocs_txfill.x iocs_txyline.x iocs_txrascpy.x \
         joyget.x kbdctrl.x keepceil.x keyflush.x keyscan.x \
         mallocall.x malloc_ba_exec.x midi_reg.x mpcm_echcnt.x \
         nameck_bof.x namests_bof.x ns_sbo.x \
         openedfiles.x openkeep.x \
         pathchk.x pathlenfix.x pt_7e.x pt_dbhw.x putmes12.x putmes24.x \
         reset68k.r rewind.x run68_dos_test.x \
         si_acc.x si_emu.x si_memory.x si_midi.x si_model.x si_phantomx.x si_scsiex.x si_sram.x \
         sjis_tbl.x skeyset.x sp3tx0gr2.x splimchk.x sq64k.x sram_memsize.x sysport.x \
         tokikoe.x \
         uskfontadr.x \
         vdispst_time.x \
         zerounit.sys

ifndef USE_HLKX
DO_NOT_BUILD = entryceil.x keepceil.x reset68k.r uskfontadr.x
$(warning LD=hlkx is required to build the following targets: $(DO_NOT_BUILD))
endif
TARGET = $(filter-out $(DO_NOT_BUILD),$(ALLTARGET))


all: directories $(TARGET)

directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/%.o: %.s $(OBJ_DIR) include/xputil.mac
	$(AS) $(ASFLAGS) -o $@ $<

# cancel default rule
%.x: %.s

ifdef USE_HLKX
entryceil.x: $(OBJ_DIR)/entryceil.o
	$(LD) $(LDFLAGS) -g2 -o $@ $^

keepceil.x: $(OBJ_DIR)/keepceil.o
	$(LD) $(LDFLAGS) -g2 -o $@ $^

uskfontadr.x: $(OBJ_DIR)/uskfontadr.o
	$(LD) $(LDFLAGS) -b0x6800 -o $@ $^

%.r: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -r -o $@ $^
endif

sjis_tbl.x: sjis_tbl.c
	$(CC) $(CFLAGS) -o $@ $^

%.x: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^

%.sys: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^


clean:
	-rm -f $(TARGET) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
