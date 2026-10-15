# Programmable Square-Wave Generator (Verilog HDL)

A small RTL project that generates a square wave with four selectable output frequencies. The design uses a counter and a 2-bit frequency-selection input. It was developed for learning and simulation with AMD Vivado and XSim; no physical FPGA board is required to run the RTL testbench.

## Features

- Synthesizable Verilog HDL
- Four selectable square-wave frequency modes
- Active-high synchronous reset
- Testbench for checking the output period across the four modes
- RTL schematic and XSim waveform screenshots
- Vivado Tcl script to recreate a project from the source files

## RTL architecture

The counter increments on each rising edge of the input clock. When it reaches the selected terminal count, the counter resets and `wave_out` toggles. The terminal count is selected by `freq_sel`.

![RTL schematic](docs/rtl_schematic.png)

## Frequency selection

The table below assumes a **10 MHz input clock** (100 ns period).

| `freq_sel` | Terminal count | Expected output frequency | Expected output period |
|---|---:|---:|---:|
| `2'b00` | 499 | 10 kHz | 100 µs |
| `2'b01` | 49 | 100 kHz | 10 µs |
| `2'b10` | 9 | 500 kHz | 2 µs |
| `2'b11` | 4 | 1 MHz | 1 µs |

The output toggles every `terminal_count + 1` rising edges of `clk`, so:

\[
f_{out} = \frac{f_{clk}}{2(terminal\_count + 1)}
\]

The output frequencies scale proportionally with the actual input-clock frequency. A clock constraint and appropriate pin constraints are required for a real FPGA implementation; this repository does not include board-specific pin assignments.

## Simulation evidence

These screenshots show the four `freq_sel` modes in Vivado XSim. The expected periods above are calculated from the RTL and 10 MHz clock; use the testbench output and cursor measurements to confirm each mode in your simulator.

### `freq_sel = 2'b00` — expected 10 kHz

![10 kHz mode waveform](docs/1KHz.png)

> Note: The current screenshot filename is `1KHz.png`; the RTL configuration predicts 10 kHz for this mode with a 10 MHz input clock.

### `freq_sel = 2'b01` — expected 100 kHz

![100 kHz mode waveform](docs/100KHz.png)

### `freq_sel = 2'b10` — expected 500 kHz

![500 kHz mode waveform](docs/500Khz.png)

### `freq_sel = 2'b11` — expected 1 MHz

![1 MHz mode waveform](docs/1MHz.png)

The `.wcfg` files in `waveforms/` save the XSim waveform display configuration (signals and view settings). They do not contain the RTL source or, by themselves, guarantee that a simulation has passed.

## Repository layout

```text
verilog-waveform-generator/
├── src/
│   └── waveform_generator.v
├── sim/
│   └── tb_wave_generator.v
├── scripts/
│   └── create_project.tcl
├── waveforms/
│   ├── 1kHz.wcfg
│   ├── 100kHz.wcfg
│   ├── 500kHz.wcfg
│   └── 1MHz.wcfg
├── docs/
│   ├── rtl_schematic.png
│   ├── 1KHz.png
│   ├── 100KHz.png
│   ├── 500Khz.png
│   └── 1MHz.png
├── .gitignore
├── LICENSE
└── README.md
```

## Run the simulation

### Option A — AMD Vivado / XSim

1. Open Vivado.
2. In the Tcl Console, change to this repository's directory.
3. Run:

   ```tcl
   source scripts/create_project.tcl
   ```

4. In the created project, select **Run Simulation → Run Behavioral Simulation**.
5. Check the testbench output for the measured periods and pass/fail result.

The Tcl script defaults to the Kintex-7 part `xc7k70tfbv676-1`. To target a different FPGA, edit the `PART` value near the top of the script before running it. This project has been explored through simulation; no physical FPGA board was used.

### Option B — Other Verilog simulators

Compile `src/waveform_generator.v` and `sim/tb_wave_generator.v` together using a Verilog-2001-compatible simulator. The testbench uses `$dumpfile` and `$dumpvars` for waveform output; simulator support for VCD generation may vary.

## Design notes

- `rst` is an **active-high synchronous reset**. It is sampled on the rising edge of `clk`.
- `freq_sel` is combinationally decoded to choose the terminal count. Change it while reset is asserted for deterministic mode changes.
- This is a square-wave generator, not a general arbitrary-waveform generator: it does not generate sine, triangle, or user-defined samples.
- RTL simulation verifies simulated behavior; it does not replace timing analysis, implementation, or hardware validation.

## Synthesis snapshot

The supplied Vivado 2025.2 synthesis report for `xc7k70tfbv676-1` listed **9 Slice LUTs** and **10 Slice Registers**. These are synthesis-stage figures from that report, not post-implementation or measured hardware results. Re-run synthesis if you change the RTL, target part, or tool version.

## License

Released under the MIT License. See [LICENSE](LICENSE).
