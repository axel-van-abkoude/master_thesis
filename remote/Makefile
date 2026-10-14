BUILD_DIR ?= build
TARGETS ?= cuda

CUR_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SAC2C_EXEC := $(CUR_DIR)bin/sac2c
.PHONY: build clean

all: build

build:
	cmake -B $(BUILD_DIR) -DTARGETS='$(TARGETS)' -DSAC2C_EXEC=$(SAC2C_EXEC)
	+cmake --build $(BUILD_DIR)

clean:
	$(RM) -r $(BUILD_DIR)
