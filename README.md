# Raspberry Pi Systems & Performance Lab

以 Raspberry Pi 3 Model B+ 與 64-bit Raspberry Pi OS，透過可重現的 C
實驗觀察 compiler、ARM64 instructions、CPU、cache、memory 與 Linux 執行環境
之間的關係。

## Project status

- Hardware／OS bring-up：完成
- Week 1：進行中
- Week 2：尚未開始
- Week 3：尚未開始

詳細範圍與驗收條件請見 `REQUIREMENTS.md`；執行進度請見
`PROJECT_PLAN.md`。

## Repository layout

```text
benchmarks/        Cache、memory 與 compiler experiments
debug-labs/        GDB、memory corruption 與 ARM64 labs
scripts/           環境收集與 benchmark automation
results/           原始量測結果
plots/             由原始結果產生的圖表
docs/              Root-cause report 與技術分析
```

## Quick start

目前 repository 仍在 Week 1 scaffolding 階段。可先檢查可用指令：

```bash
make help
```

建置、實驗與重現方式會隨各 module 完成後補齊。
