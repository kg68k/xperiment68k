# Makefile for Xperiment68k (convert source code from UTF-8 to Shift_JIS)
#   Do not use non-ASCII characters in this file.

MKDIR_P = mkdir -p
U8TOSJ = u8tosj

SRC_DIR = src
INC_DIR = $(SRC_DIR)/include
BLD_DIR = build
BLD_INC_DIR = $(BLD_DIR)/include


SRCS = $(wildcard $(INC_DIR)/* $(SRC_DIR)/*)
SJ_SRCS = $(subst $(SRC_DIR)/,$(BLD_DIR)/,$(SRCS))


.PHONY: all directories clean

all: directories $(SJ_SRCS)

directories: $(BLD_DIR) $(BLD_INC_DIR)

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
