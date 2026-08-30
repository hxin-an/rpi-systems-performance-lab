# GDB Lab 1: Sensor lookup crash

## Goal

Diagnose a reproducible segmentation fault without being told its root cause.
Use runtime evidence instead of guessing from the source.

## Rules

1. Build and run the program before reading `crash.c` closely.
2. Do not change the source until the root cause is supported by GDB evidence.
3. Keep the crash location separate from the code decision that caused it.

## Build

```sh
make
```

The lab deliberately uses `-g -O0`:

- `-g` includes source-level debug information.
- `-O0` keeps the generated program close to the source while learning GDB.

## First observation

```sh
./crash
```

Record only what the shell reports. The next step is to reproduce the failure
inside GDB.

## Completion criteria

- Reproduce the failure with `run`.
- Use `backtrace` to describe the call path.
- Inspect at least two stack frames with `frame`.
- Use `print` to identify the invalid program state.
- State the root cause before editing the source.
- Fix the program and verify both the failing and valid input paths.
