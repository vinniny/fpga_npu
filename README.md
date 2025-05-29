# Multi-FPGA Neural Processing Unit (NPU) on Sipeed Tang Nano 9K

## Overview

This project implements a Neural Processing Unit (NPU) on the Sipeed Tang Nano 9K (Gowin GW1NR-9C FPGA) for matrix operations, including convolution, addition, subtraction, and dot product. Designed for a multi-FPGA system, it targets efficient matrix processing with a 16×16 matrix size and a 4x4 tiling strategy, operating at a system clock of 47.25 MHz and an SPI clock of 50 MHz. The project is developed using Gowin EDA (V1.9.11.02) and verified with ModelSim 10.1d.

## Features

- **FPGA**: Gowin GW1NR-9C (8,640 LUTs, 5 DSP blocks, 468 Kb BRAM, 71 GPIOs).
- **Matrix Size**: 16×16 (optimized for low resource usage).
- **Precision**: 8-bit inputs, 16-bit outputs, 24-bit accumulators.
- **Memory**: Utilizes Block SRAM (BSRAM) for matrix storage.
- **Clocks**:
  - System clock: 47.25 MHz (21.164 ns period).
  - SPI clock: 50 MHz (20 ns period).
- **Operations**: Matrix convolution, addition, subtraction, dot product.
- **SPI Interface**: `spi_slave` module for data transfer.
- **Resource Usage**: ~3,201 LUTs (41%), ~2,757 registers (42%), 3 BSRAMs (12%), 5 DSPs.
- **Timing**: Meets 47.25 MHz (slack ~3.691 ns).

## Project Structure

- **src/**: Source files for the NPU design
  - `spi_slave.sv`: SPI slave module for communication.
  - `tile_processor.sv`: Core tile processing unit integrating matrix operations.
  - `matrix_subtraction.sv`: Matrix subtraction module (verified with 16,000/16,000 checks).
  - `matrix_addition.sv`: Matrix addition module.
  - `matrix_convolution.sv`: Matrix convolution module.
  - `matrix_dot.sv`: Matrix dot product module.
  - `top_npu_system.sv`: Top-level module integrating components.
  - `tb_spi_slave.sv`: Testbench for `spi_slave` (1000 test cases).
  - `tb_matrix_convolution_debug.sv`: Testbench for matrix operations and integration.
- **constraints/**: Constraint files
  - `fpga_npu.cst`: Physical constraints (e.g., SPI pin 52 per **PR1014**).
- **project/**: Gowin EDA project file
  - `fpga_npu.gprj`: Project configuration (excludes `matrix_multiplier.sv`).

**Note**: The `matrix_multiplier.sv` module is excluded from the current design to optimize resource usage and meet timing constraints.

## Prerequisites

- **Hardware**: Sipeed Tang Nano 9K (GW1NR-LV9QN88PC6/I5).
- **Software**: Gowin FPGA Designer v1.9.11.02 (64-bit).
- **Simulation Tool**: ModelSim ALTERA v10.1d.
- **Language**: SystemVerilog 2017.
- **Library**: Gowin FPGA simulation library (`prim_tsim.v`) at `C:/Gowin/Gowin_V1.9.11.02_x64/IDE/simlib/gw1n/prim_tsim.v`.
- **OS**: Windows (project path: `C:/Users/thanh/Desktop/FPGA projects/Demo4/fpga_npu/`).

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd multi-fpga-npu
   ```

2. **Install Gowin EDA**:
   - Download and install Gowin FPGA Designer v1.9.11.02 from [Gowin Semiconductor](https://www.gowinsemi.com/en/support/).
   - Ensure the library path `C:/Gowin/Gowin_V1.9.11.02_x64/IDE/simlib/gw1n/` is accessible.

3. **Install ModelSim**:
   - Install ModelSim ALTERA v10.1d.
   - Configure for SystemVerilog 2017 support.

4. **Directory Setup**:
   - Place source files in `C:/Users/thanh/Desktop/FPGA projects/Demo4/fpga_npu/src/`.
   - Include `fpga_npu.cst` with:
     ```verilog
     create_clock -name clk -period 21.164 [get_ports clk] // 47.25 MHz
     create_clock -name sclk -period 20 [get_ports sclk] // 50 MHz
     set_attribute -name MAX_DSP -value 5 -type integer
     IO_LOC "sclk" 52; // SPI pin 52 per PR1014
     ```
   - Verify `fpga_npu.gprj` excludes `matrix_multiplier.sv`.

## Simulation

### SPI Slave Simulation

1. **Compile and Run**:
   ```tcl
   vlib work
   vlog -work work C:/Gowin/Gowin_V1.9.11.02_x64/IDE/simlib/gw1n/prim_tsim.v
   vlog -work work ../src/spi_slave.sv
   vlog -work work ../src/tb_spi_slave.sv
   vsim -voptargs=+acc work.tb_spi_slave
   add wave -r /*
   run -all
   ```
2. **Expected Output**:
   - Runs 1000 test cases, verifying SPI outputs (`cmd`, `tile_i`, `tile_j`, `op_code`, `data_in`) and `miso`.
   - Success: `Test completed: 2000/2000 checks passed` (~2.4 ms).
   - Debug: If failures occur, inspect `state`, `bit_cnt`, `valid_sclk`, `valid_sync2`, `data_out_sync2`, `miso`, `shift_reg` in waveforms.

### Tile Processor Simulation

1. **Compile and Run**:
   ```tcl
   vlib work
   vlog -work work C:/Gowin/Gowin_V1.9.11.02_x64/IDE/simlib/gw1n/prim_tsim.v
   vlog -work work ../src/matrix_convolution.sv
   vlog -work work ../src/matrix_addition.sv
   vlog -work work ../src/matrix_subtraction.sv
   vlog -work work ../src/matrix_dot.sv
   vlog -work work ../src/spi_slave.sv
   vlog -work work ../src/tile_processor.sv
   vlog -work work ../src/tb_matrix_convolution_debug.sv
   vsim -voptargs=+acc work.tb_matrix_convolution_debug
   run -all
   ```
2. **Expected Output**:
   - Verifies matrix operations, expecting `16000/16000 checks passed`.
   - Test `tb_npu_top` (if available) for `SUB` and `MUL` operations (`final_result=0` for `MUL`).

## Synthesis and Programming

1. **Open Project**:
   - Launch Gowin FPGA Designer and open `fpga_npu.gprj`.
   - Confirm device: GW1NR-LV9QN88PC6/I5.

2. **Apply Constraints**:
   - Ensure `fpga_npu.cst` is included with clock definitions and SPI pin 52 assignment (**PR1014**).

3. **Synthesize**:
   - Run synthesis in Gowin FPGA Designer.
   - Check `fpga_npu_syn.rpt.html` for timing (expected slack ~3.691 ns).
   - Verify resource usage: ~3,201 LUTs, ~2,757 registers, 3 BSRAMs, 5 DSPs.
   - Confirm no errors (**EX3791**, **EX3784**, **EX2442**, **EX3630**, **EX3147**).

4. **Program FPGA**:
   - Generate bitstream in Gowin FPGA Designer.
   - Program the Tang Nano 9K using Gowin Programmer.

5. **Test**:
   - Use SPI commands to input 16×16 matrices via `spi_slave`.
   - Verify matrix operations (convolution, subtraction, etc.) via outputs.

## Achievements

- **Simulation Success**:
  - `matrix_subtraction.sv`: Achieved 16,000/16,000 checks passed at 47.25 MHz.
  - `spi_slave.sv`: Ongoing optimization to achieve 2000/2000 checks in `tb_spi_slave`.
- **Resolved Issues**:
  - **PR1014**: SPI pin 52 correctly assigned in `fpga_npu.cst`.
  - **CT1135**: Optimized `matrix_subtraction` for 47.25 MHz timing.
  - **CK3000**: Ensured robust clock domain crossing in `spi_slave` synchronization.
  - **EX3784**, **EX2442**, **EX3630**, **EX3147**, **EX3791**: Addressed through synthesis constraints and module updates.
- **Resource Optimization**: Reduced LUT usage to ~41% by excluding `matrix_multiplier.sv` and optimizing tiling.
- **Timing**: Meets 47.25 MHz with sufficient slack (~3.691 ns).

## Known Issues

- **SPI Slave Verification**: Recent `tb_spi_slave` runs show 9/2000 checks passed, indicating issues with `miso` timing and SPI outputs. Under active debug with waveform analysis (`bit_cnt`, `state`, `shift_reg`).
- **Multi-FPGA Coordination**: Not yet tested; requires `tb_npu_top` for validation.

## Future Steps

- **SPI Slave Optimization**: Achieve 2000/2000 checks in `tb_spi_slave` by refining `miso` timing and `shift_reg` capture.
- **100 MHz Operation**: Implement PLL to increase clock to 100 MHz, potentially doubling performance.
- **Multi-FPGA Testing**: Validate coordination across multiple Tang Nano 9K boards using `top_npu_system`.
- **Additional Operations**: Integrate ReLU, pooling, or other neural network layers.
- **External Host**: Develop interface with DE-10 or DE-2 board using RISC-V softcore for data orchestration.

## Acknowledgments

- Built with Gowin FPGA Designer v1.9.11.02 and Sipeed Tang Nano 9K.
- References: *Gowin FPGA Designer User Manual* (V1.9.11, 2024), *Gowin Synthesis Constraints Guide* (2024).

---

*Last Updated: May 29, 2025*