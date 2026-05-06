## How it works

"Space-Time Waves and Filaments" is a purely combinatorial generative hardware video synthesizer written in Verilog. It calculates continuously evolving procedural art in real-time for a 640x480 VGA display at 60Hz.

The design features a custom VGA sync engine that drives a screen-space coordinate system. By treating the center of the screen (320, 240) as the geometric origin, the hardware generates perfectly symmetrical patterns using absolute distances (`cx`, `cy`) and octagonal approximations.

Instead of relying on RAM or expensive DSP blocks for sines and cosines, the visual engines rely entirely on bitwise operations (like XOR fractals) and moving triangle waves. An internal frame counter acts as the flow of "time," continuously shifting the geometry and color palettes to create a smooth 60fps animation. 

A multiplexer routes one of four mathematical art engines to the output based on the state of the input pins:
* **Default:** The Cosmic Web "Black Hole" (A rotational XOR fractal)
* **Engine 1:** Rolling Ocean Waves (Interfering pseudo-sine waves)
* **Engine 2:** Red, White, & Blue Spider Web (Distance-based geometric spokes and rings)
* **Engine 3:** The Centered Tunnel (A collapsing XOR geometry)

## How to test

To test the synthesizer, you will need to provide a standard 25.175 MHz clock to drive the VGA timing correctly. 

1. Connect a VGA monitor to the output pins via a standard Tiny VGA PMOD (or an equivalent resistor-ladder DAC).
2. Apply the 25.175 MHz clock and reset the design. You should immediately see the default **Cosmic Web** animation on the screen.
3. Use the input pins to toggle between the different generative modes:
    * **Toggle `ui_in[0]` HIGH:** Displays the Rolling Ocean Waves.
    * **Toggle `ui_in[1]` HIGH:** Displays the Red, White, and Blue Spider Web.
    * **Toggle `ui_in[2]` HIGH:** Displays the Centered Tunnel.
    * *(Note: The inputs have a built-in priority. `ui_in[2]` will override `ui_in[1]`, which overrides `ui_in[0]`.)*

## External hardware

* **Tiny VGA PMOD** (or compatible 3-bit-per-channel R2R DAC).
* A standard VGA cable and a monitor capable of supporting 640x480 resolution at 60Hz.
* DIP switches or buttons connected to the input pins to change the visual modes.
