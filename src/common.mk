# Makefile for Xperiment68k (common)

INCLUDE_DIR = ../include
OBJ_DIR = o

CC = gcc2
CFLAGS = -Wall -O2
AS = has060
ASFLAGS = -w -i$(INCLUDE_DIR)
LD ?= hlk
LDFLAGS =
MKDIR_P = mkdir -p


.PHONY: all directories clean
.PRECIOUS: $(OBJ_DIR)/%.o


all: directories $(TARGET)

directories: $(OBJ_DIR)

$(OBJ_DIR):
	$(MKDIR_P) $@


$(OBJ_DIR)/%.o: %.s $(OBJ_DIR) $(INCLUDE_DIR)/xputil.mac
	$(AS) $(ASFLAGS) -o $@ $<

# cancel default rule
%.x: %.s

%.r: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -r -o $@ $^

%.x: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^

%.sys: $(OBJ_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^


clean:
	-rm -f $(TARGET) $(OBJS)
	rmdir $(OBJ_DIR)


# EOF
