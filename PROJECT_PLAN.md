# Raspberry Pi Systems & Performance Lab — 執行計畫

## 1. 文件定位

- `REQUIREMENTS.md` 是專案範圍、需求與驗收條件的唯一依據。
- 本文件將需求轉成可執行、可勾選的三週工作清單。
- 未經討論，不將新產品功能加入必做範圍。
- `rpi-healthd`、感測器、Web dashboard、MQTT、kernel module、bare metal 與完整 OSC labs 均不在目前計畫內。

狀態標記：

- `[x]` 已完成
- `[ ]` 待完成
- `[-]` 選做或暫緩

## 2. 目前狀態（2026-08-24）

### Hardware／OS bring-up

- [x] 確認 Target 為 Raspberry Pi 3 Model B+
- [x] 準備 microSD、獨立電源與 FT232RNL USB-to-TTL
- [x] FT232RNL 設為 3.3V；僅連接 GND、RXD、TXD，不連接 VCC
- [x] 寫入 Raspberry Pi OS Lite 64-bit
- [x] 確認系統為 Debian 13 Trixie、AArch64
- [x] 設定主機名稱 `rpi-lab`
- [x] 設定 Wi-Fi 並確認取得 DHCP 區域網路位址
- [x] 建立專用 Ed25519 SSH key
- [x] 設定 SSH 公鑰登入
- [x] 在 Mac 設定 `ssh rpi` 縮寫
- [x] 驗證 SSH 可登入
- [x] 接妥 FT232RNL UART：Pin 6 GND、Pin 8 TXD、Pin 10 RXD
- [x] 啟用 UART hardware 與 serial console
- [x] 以 115200 8N1 看見 Linux 開機紀錄

### Bring-up 驗收

- [x] Wi-Fi 正常時可使用 `ssh rpi`
- [x] 網路異常時可透過 UART 觀察開機與登入
- [x] 能解釋 SSH、UART 與 USB-to-TTL 的用途及差異

> 注意：IPv4 位址由 DHCP 配發，日後可能改變。若 `ssh rpi` 失效，先重新確認 Pi 的 IP，再更新 Mac 的 `~/.ssh/config`。

## 3. Week 1：Linux、GDB、ARM64

### W1-1 Repository scaffold

- [x] 初始化 Git repository
- [x] 建立 `benchmarks/`、`debug-labs/`、`scripts/`、`results/`、`plots/`、`docs/`
- [x] 建立最小 `README.md`、`.gitignore` 與 `Makefile`
- [x] 完成第一次本地 commit

產出：可建置的 repository 骨架。

### W1-2 開發工具與環境盤點

- [x] 安裝或確認 GCC、GDB、Git、Make、CMake、Python 與 `perf`
- [x] 記錄工具版本
- [x] 確認 `perf` 在 Pi 3B+／目前 kernel 可使用的 events
- [x] 記錄不支援或權限不足的 events，不以零值冒充有效結果

產出：`results/tool_versions.txt` 與 `docs/perf-capabilities.md`。

### W1-3 System information collector

- [x] 撰寫 `scripts/system_info.sh`
- [x] 收集 CPU model、ISA、core count、kernel、OS、frequency、governor、cache、memory、temperature 與 compiler 版本
- [x] 指令失敗時留下可判讀訊息並回傳非零狀態
- [x] 將輸出保存為 `results/system_info.txt`
- [x] 在乾淨 shell 中重跑並確認結果可重現

產出：`scripts/system_info.sh`、`results/system_info.txt`。

### W1-4 GDB Debug Lab

- [ ] Lab 1：使用 `run`、`backtrace`、`frame`、`print` 找到 segmentation fault
- [ ] Lab 2：使用 breakpoint／watchpoint 找到 array out-of-bounds 或 memory corruption
- [ ] Lab 3：解釋 call stack、PC、SP、register 與相關 memory
- [ ] 完成 root-cause report 初稿，分開記錄現象、假設、證據、原因、修正與驗證

產出：`debug-labs/` 程式與 `docs/gdb-root-cause-report.md`。

### W1-5 C ↔ ARM64

- [ ] 以 `-g -O0` 編譯小型 C 程式
- [ ] 使用 GDB `disassemble`、`info registers`、`stepi`
- [ ] 使用 `objdump` 保存反組譯結果
- [ ] 對照 function arguments、return value、PC、SP 與 AArch64 registers
- [ ] 以自己的文字說明一段 C 如何變成 ARM64 instructions

產出：`debug-labs/arm64/` 與註解過的 assembly。

### Week 1 驗收

- [ ] 能在未知答案的情況下，用 GDB 找到一個 crash 的 root cause
- [ ] 能解釋 call stack、PC、SP、register 與 memory
- [ ] 能從 C source 單步進入 ARM64 instructions

## 4. Week 2：Cache、Memory、Compiler

### W2-1 Benchmark 基礎設施

- [ ] 建立共用計時與結果輸出方式
- [ ] 防止 compiler 移除工作負載
- [ ] 加入 warm-up、重複執行與 median 統計
- [ ] 每次記錄 compiler、flags、kernel、governor、frequency、temperature、參數與背景負載
- [ ] 原始結果使用唯一名稱保存，不覆蓋重要資料

### W2-2 Working-set benchmark

- [ ] 測試從數 KB 到明顯超過 cache 的多組 array size
- [ ] 記錄 execution time 與平台可用的 `perf` events
- [ ] 找出 working set 跨越 cache 後的效能變化
- [ ] 將 observation、hypothesis、evidence 與 conclusion 分開寫

產出：`benchmarks/cache/`、原始結果與初步分析。

### W2-3 Memory-access experiment

- [ ] 比較 sequential 與 random access
- [ ] 預先產生 random index，避免把亂數成本混入量測
- [ ] 使用相同資料量與重複次數比較
- [ ] 保存時間與可用的硬體計數器

產出：`benchmarks/memory/`、原始結果與分析。

### W2-4 Compiler optimization experiment

- [ ] 使用 `-O0`、`-O2`、`-O3` 建置相同核心程式
- [ ] 比較 runtime 與可用的 instruction／cycle 指標
- [ ] 使用 `objdump`／GDB 比較 assembly
- [ ] 註解 loop、branch、register 或 vectorization 的可觀察差異

產出：`benchmarks/compiler/`、assembly 與比較表。

### Week 2 驗收

- [ ] 能以重複量測與 assembly 證據解釋主要效能差異
- [ ] 不以單次結果或不支援的 `perf` event 下結論

## 5. Week 3：Investigation 與交付

### W3-1 Before／after 改善案例

- [ ] 從 Week 2 結果選擇一個可驗證問題
- [ ] 保存 baseline
- [ ] 提出 bottleneck hypothesis
- [ ] 實作一項修改
- [ ] 在相同條件下重複量測
- [ ] 誠實記錄改善、無改善或退步

分析順序固定為：

```text
baseline
→ measurement
→ bottleneck hypothesis
→ implementation change
→ repeated measurement
→ conclusion
```

### W3-2 自動化與結果整理

- [ ] 完成主要 benchmark 執行腳本
- [ ] 自動建立結果目錄並記錄環境與參數
- [ ] 執行失敗時回傳非零狀態
- [ ] 保留原始資料，圖表由原始資料產生
- [ ] 產生必要圖表並標示量測條件

### W3-3 Portfolio 交付

- [ ] 完成技術 README
- [ ] 完成 GDB root-cause report
- [ ] 完成 performance findings
- [ ] 完成 before／after 改善案例
- [ ] 確認他人可依 README 安裝、建置、執行並找到原始結果
- [ ] 錄製簡短 demonstration
- [ ] 撰寫可放入履歷的專案摘要
- [ ] 發布公開 GitHub repository

### Week 3 驗收

- [ ] 能完整說明 baseline、證據、假設、修改、重新量測與結論
- [ ] 能在不依賴 Agent 答案的情況下解釋專案核心發現

## 6. 選做項目

必做項目完成後才評估：

- [-] Branch prediction experiment
- [-] Pthread／multicore scaling
- [-] CPU affinity experiment
- [-] DVFS／thermal experiment
- [-] Remote `gdbserver`
- [-] 自動繪圖
- [-] GCC 與 Clang 比較

## 7. 下一個動作

1. 在 Raspberry Pi 上 clone repository，並親自執行 `scripts/system_info.sh`。
2. 閱讀報告，確認 `/proc`、`/sys` 與各硬體欄位的來源。
3. 開始 W1-4 GDB Debug Lab。
