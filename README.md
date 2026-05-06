![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Space-Time Waves and Filaments

**A purely combinatorial generative VGA hardware video synthesizer for Tiny Tapeout.**

This project calculates continuously evolving procedural art in real-time for a 640x480 VGA display at 60Hz. Instead of relying on RAM or expensive DSP blocks for sines and cosines, the visual engines rely entirely on bitwise operations, XOR fractals, and overlapping triangle waves. An internal frame counter acts as the flow of "time," continuously shifting the geometry and color palettes to create a smooth 60fps animation.

- [Read the full project datasheet](docs/info.md)

## Visual Engines

A multiplexer routes one of four mathematical art engines to the VGA output based on the state of the input pins:

* **Default (All switches off):** The Cosmic Web "Black Hole" (A rotational XOR fractal)
* **Mode 1 (`ui_in[0]` HIGH):** Rolling Ocean Waves (Interfering pseudo-sine waves)
* **Mode 2 (`ui_in[1]` HIGH):** Red, White, & Blue Spider Web (Distance-based geometric spokes and rings)
* **Mode 3 (`ui_in[2]` HIGH):** The Centered Tunnel (A collapsing XOR geometry)

*(Note: The inputs have a built-in priority. `ui_in[2]` overrides `ui_in[1]`, which overrides `ui_in[0]`.)*

## How to Test

To test the synthesizer, you will need to provide a standard **25.175 MHz clock** to drive the VGA timing correctly. 

### External Hardware Required
* **Tiny VGA PMOD** (or compatible 3-bit-per-channel R2R DAC).
* A standard VGA cable and a monitor capable of supporting 640x480 resolution at 60Hz.
* DIP switches or buttons connected to the input pins to toggle the visual modes.

### Setup
1. Connect the VGA monitor to the output pins (`uo_out`) via the Tiny VGA PMOD.
2. Apply the 25.175 MHz clock and reset the design. 
3. You should immediately see the default **Cosmic Web** animation on the screen. Toggle the input pins to explore the other patterns.

---

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

### Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)
