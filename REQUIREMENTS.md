# Raspberry Pi Systems & Performance Lab — 專案需求

## 1. 專案摘要

本專案使用 Raspberry Pi 3 Model B+ 與 64-bit Raspberry Pi OS，透過可重現的 C 語言實驗，觀察程式碼、compiler、ARM64 instructions、CPU、cache、memory 與 Linux 執行環境之間的關係。

專案預計在三週內完成。核心學習工具為 GDB、`perf`、`objdump`、GCC、Bash 與 Python。最終成果需能公開展示，並可作為後續嵌入式 Linux／軟韌專案的基礎。

## 2. 專案目標

完成專案後，使用者應能：

1. 在 Raspberry Pi 上編譯及執行 C 程式。
2. 使用 GDB 定位 crash、memory corruption 與錯誤的程式狀態。
3. 從 C source 對照到 ARM64 assembly、register 與 memory。
4. 使用 `perf` 收集並解讀可用的效能指標。
5. 解釋 compiler optimization、working set 與 memory-access pattern 對效能的影響。
6. 建立可重現的 benchmark，避免以單次或受干擾的數據下結論。
7. 完成一個具備 baseline、證據、修改與驗證的效能改善案例。
8. 將程式、原始數據、分析與操作方式整理成可公開的 repository。

## 3. 使用環境

- Target board：Raspberry Pi 3 Model B+
- Target OS：Raspberry Pi OS Lite 64-bit
- Host：Apple Silicon Mac M5
- 日常連線：Mac 透過區域網路 SSH 操作 Raspberry Pi
- 備援主控台：3.3V USB-to-TTL UART
- 主要語言：C
- 自動化語言：Bash、Python
- Compiler：GCC；Clang 僅作選擇性比較
- Debugger：GDB；`gdbserver` 為選做
- Performance tools：`perf`、`objdump`、系統提供的 `/proc` 與 `/sys`
- Version control：Git

## 4. 功能需求

### FR-1：系統資訊收集

專案必須提供一個可重複執行的腳本，至少記錄：

- CPU model 與 ISA
- CPU core 數量
- Kernel 與 OS 版本
- CPU frequency 與 governor
- Cache 資訊
- 記憶體容量
- CPU temperature
- Compiler 版本

輸出必須保存至 `results/`，供後續實驗引用。

### FR-2：GDB Debug Lab

專案必須包含可供練習的 C 程式，涵蓋：

- Segmentation fault
- Memory corruption 或 array out-of-bounds
- Function call stack
- C source 與 ARM64 instructions 對照

至少完成一份 root-cause report，包含：

1. 問題現象
2. 初始假設
3. 使用的 GDB 指令
4. 取得的證據
5. Root cause
6. 修正方式
7. 修正後的驗證

### FR-3：Working-set Benchmark

專案必須提供一個 C benchmark，比較多種資料大小。測試範圍應跨越小型 working set 至明顯超過 cache 容量的資料集。

至少記錄：

- Execution time
- Cycles（若硬體與 kernel 支援）
- Instructions（若支援）
- IPC（可由可用指標計算時）
- Cache-related events（僅限平台實際支援者）

### FR-4：Memory-access Experiment

專案必須比較 sequential access 與 random access，並記錄兩者的執行時間及可用的硬體計數器。

實驗設計必須避免把亂數產生器本身的成本混入主要量測，random access index 應預先產生。

### FR-5：Compiler Optimization Experiment

同一份核心程式至少使用以下設定建置：

- `-O0`
- `-O2`
- `-O3`

必須比較：

- Runtime
- Instruction count（若支援）
- 產生的 ARM64 assembly
- Loop、branch、register 或 vectorization 的可觀察差異

### FR-6：效能改善案例

專案必須選擇一個真實問題，依序呈現：

```text
baseline
→ measurement
→ bottleneck hypothesis
→ implementation change
→ repeated measurement
→ conclusion
```

改善案例可以選擇 cache blocking、memory layout、false sharing、branch behavior 或其他能以數據驗證的問題。

### FR-7：自動化與結果保存

專案必須提供腳本以執行主要 benchmark，且：

- 自動建立結果目錄
- 記錄執行環境與參數
- 保存原始輸出
- 不覆蓋先前的重要結果
- 執行失敗時回傳非零狀態碼

## 5. 量測與品質需求

### QR-1：避免無效 Benchmark

- 計算結果必須被使用，避免 compiler 移除工作負載。
- 實驗前必須 warm up。
- 每組設定必須重複執行多次。
- 結果至少提供 median；必要時補充 min、max 或 dispersion。
- 不以單次執行結果作為結論。

### QR-2：控制實驗條件

每次正式量測必須記錄或控制：

- Compiler 與 flags
- Kernel version
- CPU governor 與 frequency
- CPU temperature
- 工作負載參數
- 是否固定 CPU affinity
- 是否有明顯背景負載

### QR-3：驗證工具限制

- 不假設所有 `perf` events 都能在 Raspberry Pi 3B+ 使用。
- Unsupported 或 unreliable event 必須清楚標記，不得以零值代替有效結果。
- 解釋 compiler 與 branch 行為前必須查看 assembly。
- Observation、hypothesis 與 conclusion 必須分開記錄。

### QR-4：可重現性

其他人在相同或相近的 Raspberry Pi 環境中，應能依 README：

1. 安裝依賴
2. 建置程式
3. 執行主要實驗
4. 找到原始結果
5. 理解圖表與結論

## 6. 專案範圍

### 必須完成

- 系統資訊收集器
- GDB Debug Lab
- C 與 ARM64 assembly 對照
- Working-set／cache experiment
- Sequential／random memory experiment
- GCC optimization comparison
- 自動化執行與原始數據保存
- Root-cause debugging report
- 至少一個 before／after 改善案例
- 完整 README

### 選做

- Branch prediction experiment
- Pthread／multicore scaling
- CPU affinity experiment
- DVFS／thermal experiment
- Remote `gdbserver`
- 自動繪圖
- GCC 與 Clang 比較

### 暫不納入

- 外接感測器
- Web dashboard
- MQTT 或雲端服務
- Linux kernel module
- Bare-metal kernel
- 完整 OSC labs
- MCU／RTOS 開發

## 7. 三週里程碑

### Week 1：Linux、GDB、ARM64

- Raspberry Pi OS Lite 64-bit 可正常啟動
- SSH 開發流程可用
- 安裝 GCC、GDB、`perf` 與 build tools
- 完成系統資訊收集器
- 完成 GDB 練習及 root-cause report 初稿
- 能從 C source 單步進入 ARM64 instructions

驗收：可以用 GDB 找到一個未知 crash 的 root cause，並解釋 call stack、PC、SP、register 與相關 memory。

### Week 2：Cache、Memory、Compiler

- 完成 working-set benchmark
- 完成 sequential／random access 比較
- 完成 `-O0`／`-O2`／`-O3` 比較
- 保存原始結果
- 查看並註解關鍵 assembly 差異

驗收：能用量測與 assembly 證據解釋主要效能差異。

### Week 3：Investigation 與交付

- 完成一個 before／after 改善案例
- 整理執行腳本及結果
- 完成 README 與 findings
- 產生必要圖表
- 錄製簡短 demonstration

驗收：能完整呈現 baseline、證據、假設、修改、重新量測與結論。

## 8. 最終交付成果

- 可公開的 GitHub repository
- 可重現的建置與執行指令
- 原始 benchmark results
- 分析用圖表
- GDB root-cause report
- Performance findings
- Before／after 改善案例
- 技術 README
- 簡短 demo 影片
- 可放入履歷的專案摘要

## 9. Agent 與使用者分工

### Agent 可協助

- Repository scaffold
- Makefile／CMake
- Bash 與 Python automation
- 產生 debugging 練習程式
- Code review
- 實驗設計檢查
- 找出可能的干擾因素
- 圖表及 README 整理

### 使用者必須親自完成

- 操作 Raspberry Pi、GDB 與 `perf`
- 實驗前提出預測
- 判讀數據與 assembly
- 找出 root cause
- 寫出自己的觀察與結論
- 能在不依賴 Agent 答案的情況下解釋專案

## 10. 硬體安全限制

- Raspberry Pi GPIO 與 UART 使用 3.3V 邏輯。
- USB-to-TTL 型號與邏輯電位未確認前不得接線。
- UART 僅連接 GND、TXD、RXD；TX 與 RX 交叉連接。
- 不使用 USB-to-TTL 的 VCC 為 Raspberry Pi 供電。
- 接線與拔線應在 Raspberry Pi 關機及斷電時進行。

## 11. 初始 Repository 結構

```text
rpi-systems-performance-lab/
├── benchmarks/
│   ├── cache/
│   ├── memory/
│   ├── compiler/
│   └── optional/
├── debug-labs/
│   ├── crash/
│   ├── memory-corruption/
│   └── arm64/
├── scripts/
├── results/
├── plots/
├── docs/
├── Makefile
├── README.md
└── REQUIREMENTS.md
```

## 12. 下一步

在開始建立程式碼前，依序完成：

1. 盤點 Raspberry Pi、microSD 與電源。
2. 確認 USB-to-TTL 型號、接腳與 3.3V 邏輯。
3. 準備 Raspberry Pi OS Lite 64-bit 映像。
4. 建立 SSH 連線。
5. 初始化 Git repository 與專案骨架。
