# FPGA Music Player on AC620V2

## 中文简介

这是一个“高级数字系统”课程设计项目，基于 AC620V2 FPGA 开发板实现一个乐曲播放器。系统使用 WM8731 音频芯片输出声音，使用板载 8 位七段数码管显示歌曲序号、播放时间、当前简谱、音区和播放状态。

该仓库是公开展示版，已移除 Quartus 中间文件、历史测试顶层、旧调试文件和仿真目录，仅保留最终版本重新编译所需 RTL、精简 Quartus 工程文件、最终 SOF 和说明文档。

## English Short Description

This is an FPGA music player project for the AC620V2 development board. It plays three built-in songs through the WM8731 audio codec and shows runtime status on an 8-digit seven-segment display driven by cascaded 74HC595 shift registers.

## 硬件平台

- Board: Xiaomeige / Xinluheng AC620V2
- FPGA: Intel / Altera Cyclone IV E `EP4CE10F17C8`
- Toolchain: Quartus Prime 18.1
- System clock: 50 MHz
- Audio codec: WM8731
- Display: 8-digit seven-segment display through two cascaded 74HC595 chips

## 已实现功能

- 三首内置歌曲播放
- S1 播放 / 暂停
- 暂停时音频静音
- S2 下一首切换
- WM8731 I2C 初始化与音频输出
- 数码管显示歌曲序号、播放时间、当前简谱、音区和播放状态
- AC620V2 专用 74HC595 数码管驱动

## 系统框图

```text
S0 rst_n     S1 Play/Pause     S2 Next
    |              |              |
    +--------------+--------------+
                   |
                   v
    +-----------------------------------------+
    | qy0768_three_song_ac620v2_seg7_test     |
    | final top module                        |
    +-------------------+---------------------+
                        |
        +---------------+----------------+
        |                                |
        v                                v
+-------------------+          +----------------------+
| Playback control  |          | Display state format |
| song_id / playing |          | time / note / state  |
+---------+---------+          +----------+-----------+
          |                               |
          v                               v
+-------------------+          +----------------------+
| Song ROM 0 / 1 / 2|          | AC620V2 SEG7 driver  |
| note sequence     |          | 74HC595 serial drive |
+---------+---------+          +----------+-----------+
          |                               |
          v                               v
+-------------------+          +----------------------+
| Tone generator    |          | 8-digit 7-segment    |
| note table/divider|          | display              |
+---------+---------+          +----------------------+
          |
          v
+-------------------+       I2C config       +----------------+
| audio_tx          | <---------------------> | WM8731 codec   |
| DAC clocks/data   |                         | AUDIO OUT      |
+-------------------+                         +----------------+
```

## 最终顶层

```text
rtl/qy0768_three_song_ac620v2_seg7_test.v
```

Top-level entity:

```text
qy0768_three_song_ac620v2_seg7_test
```

## 最终 SOF

```text
release/final_sof/qy0768_three_song_ac620v2_seg7_test.sof
```

## 按键说明

| Board key | FPGA pin / signal | Function |
| --- | --- | --- |
| S0 | `rst_n`, `PIN_M16` | Active-low reset |
| S1 | `PIN_E15` | Play / pause |
| S2 | `PIN_E16` | Next song |

## 数码管显示格式

| Digit | Content | Description |
| --- | --- | --- |
| `[7]` | Song number | 1 / 2 / 3 |
| `[6]` | Blank | Separator |
| `[5]` | Seconds tens | Playback time |
| `[4]` | Seconds ones | Playback time |
| `[3]` | Blank | Separator |
| `[2]` | Current numbered note | 1~7 |
| `[1]` | Octave area | Low = d segment, middle = g segment, high = a segment |
| `[0]` | Play state | 1 = playing, 0 = paused |

## 开发与验证流程

1. LED 心跳和 S0 复位测试
2. WM8731 固定音输出测试
3. ROM0 单曲播放测试
4. 三首歌两按键控制测试
5. 数码管 clean 静态显示测试
6. AC620V2 专用 74HC595 数码管驱动测试
7. 最终音乐显示系统上板通过

More details:

- [Development Flow](docs/development_flow.md)
- [7-Segment Debug Notes](docs/seg7_debug_notes.md)
- [System Architecture](docs/system_architecture.md)
- [Final Release Notes](docs/final_release_notes.md)

## 项目亮点

- 从硬件原理图确认 AC620V2 数码管两片 74HC595 的真实级联顺序。
- 针对 AC620V2 实现独立数码管驱动：`shift_word = {~seg_logic, dig_hw}`，MSB first。
- 音频链路和显示链路分阶段验证，最终再集成，降低调试复杂度。
- 暂停时保持播放状态，同时对 tone generator 输入静音音符，实现暂停静音。

## 上板验证状态

最终版本已在 AC620V2 开发板完成上板验证：

- WM8731 音频输出正常
- 三首歌曲播放正常
- S1 播放 / 暂停正常
- 暂停静音正常
- S2 下一首正常
- 数码管显示正常

## 未实现功能说明

本项目最终版本未实现以下扩展功能：

- UART 动态传谱
- 上一首切换
- 多倍速快进

## Keywords

`Verilog` `FPGA` `WM8731` `I2C` `I2S` `74HC595` `7-Segment Display` `Quartus`
