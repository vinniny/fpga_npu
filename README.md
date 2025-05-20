# Multi-FPGA Neural Processing Unit (NPU) on Sipeed Tang Nano 9K

## Overview

This project implements a Neural Processing Unit (NPU) on the Sipeed Tang Nano 9K (Gowin GW1NR-9C FPGA) for matrix operations, including multiplication, convolution, addition, subtraction, and dot product. Designed for a multi-FPGA system, it can achieves \~0.384 GMAC/s per FPGA at 50 MHz (\~1.536 GMAC/s across 4 FPGAs) with a 16×16 matrix size and 4x4 tiling strategy.

## Features

- **FPGA**: Gowin GW1NR-9C (8,640 LUTs, 5 DSP blocks, 468 Kb BRAM, 71 GPIOs).
- **Matrix Size**: 16×16 (512 MACs for multiplication, 144 MACs for 3×3 convolution).
- **Precision**: 8-bit inputs, 16-bit outputs, 24-bit accumulators.
- **Memory**: 3 SRAMs (6 Kb, \~1.28% of 468 Kb).
- **Clock**: 50 MHz (Fmax 56.811 MHz), with potential for 100 MHz (\~0.768 GMAC/s per FPGA).
- **Operations**: Matrix multiplication, convolution, addition, subtraction, dot product.
- **Resource Usage**: \~3,201 LUTs (41%), 2,757 registers (42%), 3 BSRAMs (12%), 5 DSPs.

## Project Structure

- **Source Files**:
  - `matrix_multiplier.sv`: Matrix multiplication (4x4 tiles, 5 DSPs).
  - `matrix_convolution.sv`: 3×3 convolution (6x6 input tile, 5 DSPs).
  - `matrix_addition.sv`, `matrix_subtraction.sv`: Element-wise operations.
  - `matrix_dot.v`: Dot product (LUT-based).
  - `tile_processor.v`: Orchestrates operations with SRAM access.
  - `spi_slave.sv`: SPI interface for data transfer.
  - `top.sv`, `top_npu_system.sv`: Top-level modules.
  - `sram_A.sv`, `sram_B.sv`, `sram_C.sv`: SRAM modules.
  - `gowin_multaddalu.v`: DSP primitive.
- **Project File**: `fpga_npu.gprj`
- **Constraints**: `fpga_npu.cst` (50 MHz clock, 5 DSPs max).

## Setup Instructions

### Prerequisites

- **Hardware**: Sipeed Tang Nano 9K (GW1NR-LV9QN88PC6/I5).
- **Software**: Gowin FPGA Designer v1.9.11.02 (64-bit).
- **Tools**: Verilog/SystemVerilog simulator (e.g., ModelSim, Vivado Simulator).

### Installation

1. **Clone Repository**:

   ```bash
   git clone <repository_url>
   cd multi-fpga-npu
   ```
2. **Open Project**:
   - Launch Gowin FPGA Designer.
   - Open `fpga_npu.gprj`.
   - Verify device: GW1NR-LV9QN88PC6/I5.
3. **Add Constraints**:
   - Include `fpga_npu.cst` in Project &gt; Constraints &gt; Add File.
   - Contents:

     ```verilog
     create_clock -name clk -period 20 [get_ports clk] // 50 MHz
     create_clock -name sclk -period 20 [get_ports sclk]
     set_attribute -name MAX_DSP -value 5 -type integer
     ```

### Synthesis and Programming

1. **Synthesize**:
   - Run synthesis in Gowin FPGA Designer.
   - Verify no warnings/errors (e.g., EX3791, RP0002, RP0006).
   - Check resource usage: \~3,201 LUTs, 5 DSPs, 3 BSRAMs.
2. **Program FPGA**:
   - Generate bitstream.
   - Program the Tang Nano 9K using Gowin Programmer.
3. **Test**:
   - Use SPI commands to input 16×16 matrices.
   - Verify operations (multiplication, convolution, etc.) via outputs.

## Achievements

- **Resolved Errors**:
  - **RP0006**: Reduced logic from 12,308 to \~3,201 LUTs by shrinking matrix size to 16×16 and optimizing tiling.
  - **RP0002**: Limited DSPs to 5 using explicit instantiation and constraints.
- **Eliminated Warnings**:
  - Resolved all **EX3791** truncation warnings by adjusting bit-widths (`iter`, `m`, `n` to 3 bits; `i`, `j`, `k` to 5 bits) and explicit casting (e.g., `k <= 4'(k + 1)`).
- **Performance**: Achieved \~0.384 GMAC/s at 50 MHz, with potential for \~0.768 GMAC/s at 100 MHz.
- **Timing**: Meets 50 MHz (critical path \~17.928 ns, slack 2.398 ns, Fmax 56.811 MHz).

## Future Steps

- **100 MHz Optimization**: Implement PLL to achieve \~0.768 GMAC/s per FPGA (\~3.072 GMAC/s for 4 FPGAs).
- **Hardware Testing**: Validate multi-FPGA coordination with real-world neural network workloads.
- **Expand Operations**: Add support for additional layers (e.g., ReLU, pooling).
- External Host: Using DE-10 or DE-2 with RISC-V softcore for the main host.

## Acknowledgments

- Built with Gowin FPGA Designer and Sipeed Tang Nano 9K.

---

*Last Updated: May 20, 2025*
