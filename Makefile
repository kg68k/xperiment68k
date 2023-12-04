# Makefile for Xperiment68k (convert source code from UTF-8 to Shift_JIS)
#   Do not use non-ASCII characters in this file.

MKDIR_P = mkdir -p
U8TOSJ = u8tosj

SRCDIR_MK = srcdir.mk
SRC_DIR = src
-include $(SRCDIR_MK)

INC_DIR = $(SRC_DIR)/include
BLD_DIR = build
BLD_INC_DIR = $(BLD_DIR)/include


SRCS = $(wildcard $(INC_DIR)/* $(SRC_DIR)/*)
SJ_SRCS = $(subst $(SRC_DIR)/,$(BLD_DIR)/,$(SRCS))


.PHONY: all directories clean

all: directories $(SJ_SRCS)

directories: $(BLD_DIR) $(BLD_INC_DIR)

# Do not use $(SRCDIR_MK) as the target name to prevent automatic remaking of the makefile.
srcdir_mk:
	rm -f $(SRCDIR_MK)
	echo "SRC_DIR = $(CURDIR)/src" > $(SRCDIR_MK)


$(BLD_DIR) $(BLD_INC_DIR):
	$(MKDIR_P) $@


# convert src/* (UTF-8) to build/* (Shift_JIS)
$(BLD_INC_DIR)/%: $(INC_DIR)/%
	$(U8TOSJ) < $^ >! $@

$(BLD_DIR)/%: $(SRC_DIR)/%
	$(U8TOSJ) < $^ >! $@



clean:
	-rm -f $(SJ_SRCS)
	-rmdir $(BLD_INC_DIR) $(BLD_DIR)


# EOF
