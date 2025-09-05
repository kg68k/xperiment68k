# Makefile for Xperiment68k (process)

TARGET = \
         a2arg.x a2arg_nh.x bindno.x crampedexec.x dumpenv.x dumpstupreg.x entryceil.x \
         execas.x keepceil.x keepcmem.x lineage.x loadonly.x mallocall.x malloc_ba_exec.x \
         openkeep.x pathchk.x sysstack_exec.x

include ../common.mk

entryceil.x: $(OBJ_DIR)/entryceil.o
	$(LD) $(LDFLAGS) -g2 -o $@ $^

keepceil.x: $(OBJ_DIR)/keepceil.o
	$(LD) $(LDFLAGS) -g2 -o $@ $^

# EOF
