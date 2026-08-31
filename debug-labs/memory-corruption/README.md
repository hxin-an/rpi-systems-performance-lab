# Memory Corruption Lab

This lab demonstrates an out-of-bounds array write that silently changes a
nearby field. The program does not necessarily crash at the instruction that
causes the bug.

## Learning goals

- distinguish the symptom from the write that caused it;
- use a GDB hardware watchpoint to stop when data changes;
- inspect loop state and the relevant memory addresses;
- compare GDB evidence with compiler sanitizer output;
- fix an off-by-one loop condition and verify both paths.

## Build and reproduce

```sh
make
./corruption
echo $?
```

Expected symptom:

```text
before: status = 1
after:  status = 104
memory corruption detected
```

The first question is not "where was the bad status printed?" but "where did
`status` change from `1` to `104`?"

## GDB investigation

```gdb
gdb ./corruption
break main
run
next
watch buffer.status
continue
backtrace
print index
print buffer->samples[index]
```

Depending on the exact line where the first `next` stops, use another `next`
until the initialization of `buffer` has completed before setting the
watchpoint.

Useful follow-up commands:

```gdb
print &buffer.samples[0]
print &buffer.samples[4]
print &buffer.status
x/5dw &buffer.samples[0]
```

## Sanitizer cross-check

The write lands inside the surrounding structure, so AddressSanitizer may not
report it as a whole-object overflow. This target uses
UndefinedBehaviorSanitizer, which checks the array bound directly and works
with this Raspberry Pi environment.

```sh
make sanitize
UBSAN_OPTIONS=halt_on_error=1 ./corruption-sanitize
```

## Completion criteria

- Explain why the program can corrupt data without immediately receiving
  `SIGSEGV`.
- Identify the exact loop iteration and source line that changes `status`.
- Explain why `samples[4]` and `status` have the same address on this build.
- Fix the off-by-one condition without changing the array size.
- Verify the normal binary and sanitizer build both complete successfully.
