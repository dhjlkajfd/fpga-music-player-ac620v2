# Development Flow

This document records the development and board-verification flow of the `qy0768_music` FPGA music player.

## 1. LED 心跳测试

Goal:

- Verify the 50 MHz clock input.
- Verify S0 active-low reset.
- Verify LED0 output.
- Confirm the basic Quartus compile and SOF download flow.

Result:

- LED0 blink worked.
- S0 reset worked.

## 2. WM8731 固定音测试

Goal:

- Verify WM8731 I2C configuration.
- Verify audio master clock, bit clock, LR clock and DAC data output.
- Confirm that the board can output sound through the WM8731 codec.

Result:

- Fixed tone output worked on hardware.

## 3. 单曲播放

Goal:

- Connect ROM note data, note table, tone generation and `audio_tx`.
- Verify basic note playback from ROM0.

Result:

- ROM0 single-song playback worked.
- Tone changes were audible.

## 4. 三首歌两按键控制

Goal:

- Add three built-in song ROMs.
- Add S1 play / pause.
- Add S2 next-song switching.
- Keep playback state while paused.
- Mute audio during pause.

Result:

- Three-song playback worked.
- S1 play / pause worked.
- Pause mute worked.
- S2 next song worked.

## 5. 数码管 clean 测试

Goal:

- Debug seven-segment display output separately from the audio system.
- Use direct active-high logical segment data for a static `12345678` test.

Result:

- The old generic SEG7 path was not used as the final display reference.
- The board required an AC620V2-specific 74HC595 data order.

## 6. AC620V2 专用 74HC595 数码管驱动

Goal:

- Match the AC620V2 schematic exactly.
- Implement digit scan and 16-bit 74HC595 serial transfer in a clean driver.

Final driver:

```text
rtl/qy0768_seg7_ac620v2_driver.v
```

Final hardware rule:

```verilog
shift_word = {~seg_logic, dig_hw};
```

Result:

- Static `12345678` display passed on board.

## 7. 最终音乐显示系统

Goal:

- Integrate the verified audio player and verified AC620V2 display driver.
- Show song number, playback time, current numbered note, octave area and play state.

Final top:

```text
qy0768_three_song_ac620v2_seg7_test
```

Final SOF:

```text
release/final_sof/qy0768_three_song_ac620v2_seg7_test.sof
```

Result:

- Final music display system passed board verification.
