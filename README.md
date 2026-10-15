# Programmable Square-Wave Generator (Verilog HDL)

A small RTL project that generates a square wave with four selectable output frequencies. The design uses a counter and a 2-bit frequency-selection input. It was developed for learning and simulation with AMD Vivado and XSim; no physical FPGA board is required to run the RTL testbench.

## Features

- Synthesizable Verilog HDL
- Four selectable square-wave frequencies
- Active-high synchronous reset
- Self-checking testbench measures the output period for all four modes
- Vivado Tcl script to recreate a project from the source files

## Frequency selection

The table below assumes a **10 MHz input clock** (100 ns period).

| `freq_sel` | Terminal count | Output frequency | Output period |
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

## Repository layout

```text
verilog-waveform-generator/
├── src/
│   └── waveform_generator.v
├── sim/
│   └── tb_wave_generator.v
├── scripts/
│   └── create_project.tcl
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

The testbench runs all four modes and reports the measured output period. The expected final message is `RESULT: ALL TESTS PASSED`.

The Tcl script defaults to the Kintex-7 part `xc7k70tfbv676-1`, matching the uploaded project configuration. To target a different FPGA, edit the `PART` value near the top of the script before running it.

### Option B — Other Verilog simulators

Compile `src/waveform_generator.v` and `sim/tb_wave_generator.v` together using a Verilog-2001-compatible simulator. The testbench uses `$dumpfile` and `$dumpvars` for waveform output; simulator support for VCD generation may vary.

## Design notes

- `rst` is an **active-high synchronous reset**. It is sampled on the rising edge of `clk`.
- `freq_sel` is combinationally decoded to choose the terminal count. Change it while reset is asserted for deterministic mode changes.
- This is a square-wave generator, not a general arbitrary-waveform generator: it does not generate sine, triangle, or user-defined samples.
- Simulation verifies RTL behavior; it does not replace timing analysis, implementation, or hardware validation.

## Synthesis snapshot

The supplied Vivado 2025.2 synthesis report for `xc7k70tfbv676-1` listed **9 Slice LUTs** and **10 Slice Registers**. These are synthesis-stage figures from that report, not post-implementation or measured hardware results. Re-run synthesis if you change the RTL, target part, or tool version.

## License

Released under the MIT License. See [LICENSE](LICENSE).
