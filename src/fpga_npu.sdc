//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.02 (64-bit) 
//Created Time: 2025-05-21 19:34:45
create_clock -name sclk -period 20 -waveform {0 10} [get_ports {sclk}] -add
create_clock -name rpll_clk -period 10 -waveform {0 5} [get_nets {rpll_clk}] -add
set_false_path -from [get_clocks {sclk}] -to [get_clocks {rpll_clk}] 
set_false_path -from [get_clocks {rpll_clk}] -to [get_clocks {sclk}] 
report_max_frequency -mod_ins {npu_inst/tp_inst/mul_inst}
