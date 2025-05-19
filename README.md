
# Multi-FPGA Neural Processing Unit (NPU) Architecture

This project implements a **Neural Processing Unit (NPU)** distributed across **four Tang Nano 9K FPGAs** (GW1NR-LV9QN88PC6/I5), coordinated by an **Intel DE10-Nano host platform**. Each FPGA operates as an independent matrix processing tile, designed to execute core neural network operations such as **matrix multiplication, convolution, addition, subtraction, and dot product** on **32×32 matrices** with **8-bit input precision**.

## 📌 Key Features

- **Multi-FPGA Parallelism**: Each FPGA executes a portion of the NPU workload, supporting modular expansion and concurrent computation.
- **Supported Operations**:
  - Matrix Multiplication (32×32)
  - 2D Convolution (3×3 kernel)
  - Element-wise Addition & Subtraction
  - Dot Product of matrix rows
- **Data Precision**:
  - Inputs: 8-bit
  - Outputs: 16-bit
  - Accumulators: 24-bit (ensuring full dynamic range without overflow)
- **SRAM Architecture**:
  - Three 8 Kb SRAMs per FPGA (sram_A, sram_B, sram_C)
  - Efficient access and buffering of matrix data
- **Communication Interface**:
  - SPI Slave implementation for interfacing with the DE10-Nano host
  - Compact protocol for data upload/download and control signaling

## ⚙️ Performance Target

- Achieves up to **0.43 GMAC/s per FPGA** (total ~1.7 GMAC/s for full system) under pipelined and optimized conditions.

## 🛠️ HDL Design

- Implemented entirely in **SystemVerilog** (IEEE Std 1800-2017 compliant)
- Synthesizable on Gowin Tang Nano 9K FPGAs
- Modular tile-based architecture for scalability

## 📂 Repository Contents

- `matrix_multiplier.sv` – Matrix multiplication core
- `matrix_convolution.sv` – 2D convolution engine
- `matrix_addition.sv`, `matrix_subtraction.sv` – Element-wise operators
- `matrix_dot.v` – Dot product engine
- `spi_slave.sv` – SPI interface logic
- `tile_processor.v` – Local control and operation dispatcher
- `top.sv` – Top-level per-FPGA wrapper
- `top_npu_system.sv` – Multi-FPGA integration and host coordination
