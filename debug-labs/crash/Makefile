CC = gcc
CFLAGS ?= -g -O0 -Wall -Wextra -Wpedantic

.PHONY: all clean

all: crash

crash: crash.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	$(RM) crash
	$(RM) -r crash.dSYM
