![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Space-Time Waves and Filaments

**A purely combinatorial generative VGA hardware video synthesizer for Tiny Tapeout.**

This project calculates continuously evolving procedural art in real-time for a 640x480 VGA display at 60Hz. Instead of relying on RAM or expensive DSP blocks for sines and cosines, the visual engines rely entirely on bitwise operations, XOR fractals, and overlapping triangle waves. An internal frame counter acts as the flow of "time," continuously shifting the geometry and color palettes to create a smooth 60fps animation.

To fit within the strict routing density constraints of the Tiny Tapeout ASIC tile, the engines employ a mix of high-resolution 10-bit math and intentionally downscaled 6-bit logic to balance visual fidelity with physical silicon footprint.

- [Read the full project datasheet](docs/info.md)
- [View the 3D GDS layout](https://gds-viewer.tinytapeout.com/?model=https://alephnansea.github.io/space_time_waves_and_filaments/tinytapeout.oas&pdk=sky130A)

## Visual Engines

A multiplexer routes one of six mathematical art engines to the VGA output based on the state of the input pins:

* **Default (All switches off):** The Cosmic Web "Black Hole" (A rotational XOR fractal)
* **Mode 1 (`ui_in[0]` HIGH):** Rolling Ocean Waves (Interfering pseudo-sine waves)
* **Mode 2 (`ui_in[1]` HIGH):** Red, White, & Blue Spider Web (Distance-based geometric spokes and rings)
* **Mode 3 (`ui_in[2]` HIGH):** The Centered Tunnel (A collapsing XOR geometry)
* **Mode 4 (`ui_in[3]` HIGH):** Detailed Qubit Entanglement (A high-frequency, counter-rotating Sierpinski probability field simulating quantum interference)
* **Mode 5 (`ui_in[4]` HIGH):** Super Low-Res Digital Tempest (A chaotic whirlpool rendered in chunky 16x16 macroblocks, placed on an extreme 6-bit "Math Diet" to bypass OpenLane routing congestion!)

*(Note: The inputs have a built-in strict priority. `ui_in[4]` overrides `ui_in[3]`, which overrides `ui_in[2]`, and so on down the chain.)*

## How to Test

To test the synthesizer, you will need to provide a standard **25.175 MHz clock** to drive the VGA timing correctly. 

### External Hardware Required
* **Tiny VGA PMOD** (or compatible 3-bit-per-channel R2R DAC).
* A standard VGA cable and a monitor capable of supporting 640x480 resolution at 60Hz.
* 5 DIP switches or buttons connected to the first five input pins (`ui_in[4:0]`) to toggle the visual modes.

### Setup
1. Connect the VGA monitor to the output pins (`uo_out`) via the Tiny VGA PMOD.
2. Apply the 25.175 MHz clock and reset the design. 
3. You should immediately see the default **Cosmic Web** animation on the screen. Toggle the input pins to explore the other five patterns.

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
