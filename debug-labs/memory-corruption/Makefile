CC := gcc
CFLAGS := -g -O0 -Wall -Wextra -Wpedantic

.PHONY: all clean sanitize

all: corruption

corruption: corruption.c
	$(CC) $(CFLAGS) $< -o $@

sanitize: corruption-sanitize

corruption-sanitize: corruption.c
	$(CC) $(CFLAGS) -fno-omit-frame-pointer \
		-fsanitize=undefined $< -o $@

clean:
	rm -f corruption corruption-sanitize
	rm -f -r corruption.dSYM corruption-sanitize.dSYM
