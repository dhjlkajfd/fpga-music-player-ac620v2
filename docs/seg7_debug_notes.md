# 7-Segment Display Debug Notes

## Background

The AC620V2 board uses two cascaded 74HC595 chips to drive the 8-digit seven-segment display. The final display driver was written after checking the schematic and validating the result on hardware.

## Hardware Mapping

- U6 = digit-select 74HC595
- U7 = segment-select 74HC595
- `SEG7_DIO` first enters U6 `SER`
- U6 `QH'` cascades into U7 `SER`
- U6 `QA~QH` correspond to `HEX_SEL0~HEX_SEL7`
- U7 `QA~QH` correspond to `HEX_A~HEX_DP`

## Electrical Logic

- Segment select is active-low.
- Digit select is active-high.
- Logical segment data is active-high.
- Logical segment format is `{dp,g,f,e,d,c,b,a}`.

## Final Serial Frame

The verified frame format is:

```verilog
shift_word = {~seg_logic, dig_hw};
```

Where:

- `seg_logic` is the active-high logical segment byte.
- `~seg_logic` converts the segment byte to active-low hardware output.
- `dig_hw` is one-hot active-high digit select.
- Bits are shifted MSB first.

## Static Test Result

The AC620V2-specific static display test showed:

```text
12345678
```

on the real board. After this passed, the same driver was used in the final music display system.

## Final Driver

```text
rtl/qy0768_seg7_ac620v2_driver.v
```

This driver performs both:

- 8-digit dynamic scanning
- 16-bit 74HC595 serial sending
