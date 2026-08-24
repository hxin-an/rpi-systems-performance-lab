# perf capability check

## Environment

- Target: Raspberry Pi 3 Model B+
- Architecture: AArch64
- Kernel: `6.18.34+rpt-rpi-v8`
- `perf`: `6.18.39`
- `kernel.perf_event_paranoid`: `2`
- Captured: 2026-08-24

The installed `perf` and running kernel have different patch versions. The
tested counters work, but this version difference must remain recorded with
formal results.

## Capability probe

The following command was used only to verify counter availability. It is not
a benchmark result:

```bash
perf stat \
  -e task-clock,cycles,instructions,cache-references,cache-misses,branches,branch-misses \
  -- python3 -c 'sum(range(2000000))'
```

| Event | Available as regular user | Probe value |
| --- | ---: | ---: |
| `task-clock:u` | yes | 389,492,865 ns |
| `cycles:u` | yes | 526,051,489 |
| `instructions:u` | yes | 392,815,493 |
| `cache-references:u` | yes | 154,023,691 |
| `cache-misses:u` | yes | 658,005 |
| `branches:u` | yes | 25,021,996 |
| `branch-misses:u` | yes | 617,036 |

## Interpretation and constraints

- The `:u` suffix means these measurements currently count user-space activity.
- The probe produced an IPC of about 0.75, a cache-miss ratio of about 0.43%,
  and a branch-miss ratio of about 2.47%. These numbers only prove that the
  events return plausible non-zero values; they are not project conclusions.
- Formal experiments must repeat measurements, warm up first, record the
  workload and environment, and report at least the median.
- Each event used later must be checked again on the exact kernel running at
  measurement time. Unsupported or unreliable events must be reported as such,
  never replaced with zero.
- We will prefer explicit user-space events for reproducibility and avoid
  changing `perf_event_paranoid` unless an experiment genuinely requires it.
