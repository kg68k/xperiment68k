# Makefile for Xperiment68k

ifeq ($(notdir $(CURDIR)),src)
$(error do not execute make in src directory)
endif

CC = gcc2
CFLAGS = -Wall -O2
AS = has060
ASFLAGS = -w -i./include
LD ?= hlk
LDFLAGS =
MKDIR_P = mkdir -p

OBJ_DIR = o

ifeq ($(findstring hlkx,$(LD)),hlkx)
USE_HLKX = true
endif


.PHONY: all directories clean
.PRECIOUS: $(OBJ_DIR)/%.o


ALLTARGET = \
         a2arg.x a2arg_nh.x adpcmotchk.x appendbytes.x \
         beep_adpcmout.x beep_mpcm.x beep_zmsc3.x \
         bg1pr2th.x bgexec.x bgexecd.x bgkill.x bglivingdead.x bgsprocd.x bgsprocess.x \
         bgthreadid.x bgwakeup.x bgzombie.x \
         bindno.x bitsns.x bkeyinpd3.x bputmes_cur.x buserr_2w.x \
         chxdummy.x closerewindatr.x colorbar.x conctrl_so.x con_scroll.x crampedexec.x \
         datetime.x dbrams.x defchr_7621.x \
         dos_conctrl.x dos_create_sp.x dos_curdir.x dos_fatchk.x dos_fgetc.x dos_fgets.x dos_filedate.x \
         dos_getc.x dos_getchar.x dos_getdate.x dos_getenv.x dos_gets.x dos_gettim2.x dos_gettime.x \
         dos_inkey.x dos_inpout.x dos_keyctrl01.x dos_maketmp.x dos_mkdir.x \
         dos_nameck.x dos_namests.x dos_putchar.x \
         dos_setdate.x dos_setenv.x dos_settim2.x dos_settime.x dos_vernum.x \
         dumpenv.x dumpstdin.x dumpstupreg.x \
         entryceil.x env_sbo.x esc_dsr.x exception.x exchr_hex.x execas.x exfiles.x existsdir.x \
         fatchk_bof.x \
         fe_fcvt_test.x fe_power_test.x fe_stoh_test.x \
         fileopen.x files.x fntget.x fntsize.x \
         getassign.x \
         incdir_test.x \
         iocs_b_clr_st.x iocs_b_del.x iocs_b_ins.x \
         iocs_datebcd.x iocs_datebin.x iocs_dateget.x iocs_dateset.x iocs_ontime.x \
         iocs_timebcd.x iocs_timebin.x iocs_timeget.x iocs_timeset.x \
         iocs_txfill.x iocs_txyline.x iocs_txrascpy.x ioctrl12.x ioctrl13.x \
         isemu_rtc.x \
         jfp_stat.x joyget.x \
         kbdctrl.x keepceil.x keepcmem.x keyflush.x keyscan.x \
         lineage.x \
         mallocall.x malloc_ba_exec.x midi_reg.x movem_aipi.x mpcm_echcnt.x \
         nameck_bof.x namests_bof.x newvol.x ns_sbo.x \
         openedfiles.x openkeep.x \
         pathchk.x pathlenfix.x pt_7e.x pt_dbhw.x pt_usk.x putmes12.x putmes24.x \
         reset68k.r rewind.x run68_dos_test.x runwaitchk.x \
         si_acc.x si_emu.x si_memory.x si_midi.x si_model.x si_phantomx.x si_scsiex.x si_sram.x \
         sjis_tbl.x skeyset.x sp3tx0gr2.x spchecker.x splimchk.x sq64k.x sram_memsize.x \
         super_time.x sysport.x \
         tokikoe.x tpalreset.x trap15trace.x \
         uskcg24.x uskfontadr.x uskhw_hex.x \
         vdispst_time.x \
         zerounit.sys zmsc2_gettrktbl.x zmsc2_mstat.x zmsc2_oddopm.x

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
