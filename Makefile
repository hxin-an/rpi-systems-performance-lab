CC ?= gcc
CFLAGS ?= -std=c11 -Wall -Wextra -Wpedantic -g
BUILD_DIR := build

.DEFAULT_GOAL := help

.PHONY: help all clean

help:
	@echo "Raspberry Pi Systems & Performance Lab"
	@echo ""
	@echo "Targets:"
	@echo "  make all    Build implemented experiments"
	@echo "  make clean  Remove generated build artifacts"
	@echo "  make help   Show this help"

all:
	@echo "No experiment has been implemented yet."

clean:
	$(RM) -r $(BUILD_DIR)
