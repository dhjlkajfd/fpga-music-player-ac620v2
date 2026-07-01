# Final Release Notes

## Release Identity

- Project: `qy0768_music`
- Public repository name: `fpga-music-player-ac620v2`
- Board: AC620V2
- FPGA: `EP4CE10F17C8`
- Toolchain: Quartus Prime 18.1
- Audio codec: WM8731
- Final top module: `qy0768_three_song_ac620v2_seg7_test`
- Final SOF: `release/final_sof/qy0768_three_song_ac620v2_seg7_test.sof`

## Final Top Module

```text
rtl/qy0768_three_song_ac620v2_seg7_test.v
```

The final top integrates:

- key filtering and playback control
- three song ROMs
- note playback control
- tone generation
- WM8731 audio transmission and I2C configuration
- display timer and display formatting
- AC620V2-specific 74HC595 seven-segment display driver

## Verified Functions

The final version has passed board verification:

- WM8731 audio output works.
- Three songs play correctly.
- S1 play / pause works.
- Pause mute works.
- S2 next-song switching works.
- The seven-segment display shows song number, playback time, current numbered note, octave area and play state.

## Final SOF

```text
release/final_sof/qy0768_three_song_ac620v2_seg7_test.sof
```

This is the downloadable final demonstration bitstream.

## Notes

This public repository keeps only the final project baseline. It intentionally excludes historical test top modules, Quartus temporary build folders, simulation folders and intermediate reports.
