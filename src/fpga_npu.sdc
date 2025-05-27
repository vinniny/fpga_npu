//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.02 (64-bit) 
//Created Time: 2025-05-27 15:58:12
create_clock -name clk -period 40 -waveform {0 10} [get_ports {clk}]
create_clock -name sclk -period 20 -waveform {0 10} [get_ports {sclk}]
create_clock -name rpll_clk -period 21.164 -waveform {0 10.582} [get_nets {rpll_clk}]
set_clock_groups -asynchronous -group [get_clocks {sclk}] -group [get_clocks {rpll_clk}]
set_false_path -from [get_clocks {sclk}] -to [get_clocks {rpll_clk}] 
set_false_path -from [get_clocks {rpll_clk}] -to [get_clocks {sclk}] 
