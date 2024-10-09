# Makefile to convert UTF-8 source files to Shift_JIS.
#   Do not use non-ASCII characters in this file.

MKDIR = mkdir
U8TOSJ = u8tosj

SRCDIR_MK = srcdir.mk
SRC_DIR = src
-include $(SRCDIR_MK)

BLD_DIR = build

dots = $(wildcard $(foreach w,. */. */*/. */*/*/.,$(1)/$(w)))

SRC_DIRS = $(sort $(dir $(call dots,$(SRC_DIR))))
BLD_DIRS = $(subst $(SRC_DIR)/,$(BLD_DIR)/,$(SRC_DIRS))

SRCS = $(filter-out $(SRC_DIRS:%/=%),$(wildcard $(SRC_DIRS:%=%*)))
SJ_SRCS = $(subst $(SRC_DIR),$(BLD_DIR),$(SRCS))


.PHONY: all directories srcdir_mk clean

all: directories $(SJ_SRCS)

directories: $(BLD_DIRS)

$(BLD_DIRS):
	$(MKDIR) $@

$(BLD_DIR)/%: $(SRC_DIR)/%
	$(U8TOSJ) < $^ >! $@


# Do not use $(SRCDIR_MK) as the target name to prevent automatic remaking of the makefile.
srcdir_mk:
	rm -f $(SRCDIR_MK)
	echo "SRC_DIR = $(CURDIR)/src" > $(SRCDIR_MK)


REV_BLD_DIRS = \
	$(foreach depth,3 2 1,\
		$(foreach dir,$(BLD_DIRS),\
			$(if $(filter $(depth),$(words $(subst /, ,$(dir)))),$(dir))\
		)\
	)

clean:
	rm -f $(SJ_SRCS)
	-rmdir $(REV_BLD_DIRS:%/=%)

# EOF
