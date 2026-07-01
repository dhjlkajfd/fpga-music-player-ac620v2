# System Architecture

## Overview

The final system is built around the top-level module:

```text
qy0768_three_song_ac620v2_seg7_test
```

It connects three main paths:

- audio playback path
- display path
- key control path

## Audio Path

```text
song_id
  -> song ROM 0 / 1 / 2
  -> song mux
  -> song controller
  -> current_note_id
  -> note table / tone generator
  -> audio_data
  -> qy0768_audio_tx
  -> WM8731 DAC pins
  -> AUDIO OUT / LINE OUT
```

Main RTL files:

- `qy0768_song_rom0.v`
- `qy0768_song_rom1.v`
- `qy0768_song_rom2.v`
- `qy0768_song_mux.v`
- `qy0768_song_ctrl.v`
- `qy0768_note_table.v`
- `qy0768_tone_gen.v`
- `qy0768_audio_tx.v`

## WM8731 Configuration Path

The WM8731 codec is configured over I2C during startup.

```text
qy0768_wm8731_cfg
  -> register configuration sequence
  -> qy0768_i2c_ctrl
  -> i2c_sclk / i2c_sdat
  -> WM8731
```

Main RTL files:

- `qy0768_wm8731_cfg.v`
- `qy0768_i2c_ctrl.v`

## Display Path

The display path converts playback state into seven-segment data and sends it to the AC620V2 display hardware.

```text
song_id
playing
play_sec
current_note_id
  -> qy0768_note_display_decode
  -> qy0768_display_timer
  -> qy0768_display_format
  -> seg0 ~ seg7 active-high segment data
  -> qy0768_seg7_ac620v2_driver
  -> SEG7_DIO / SEG7_SCLK / SEG7_RCLK
  -> U6 / U7 74HC595
  -> 8-digit seven-segment display
```

Main RTL files:

- `qy0768_note_display_decode.v`
- `qy0768_display_timer.v`
- `qy0768_display_format.v`
- `qy0768_seg7_ac620v2_driver.v`

## Key Control Path

```text
S1 key_play_pause
S2 key_next
  -> qy0768_key_filter
  -> qy0768_play_ctrl_frontend
  -> play_en / next_song_pulse
  -> song controller and display timer
```

S0 is reserved for active-low reset and is not used as a normal function key.

## Pause Mute Design

When playback is paused, the song controller holds its current state. Audio is muted by feeding a rest note into the tone generator:

```verilog
assign tone_note_id = play_en ? current_note_id : 5'd0;
```

This makes pause silent while allowing resume to continue from the held playback state.
