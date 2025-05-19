//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.11.01 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Tue May 13 12:27:04 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_MULTADDALU your_instance_name(
        .dout(dout), //output [36:0] dout
        .caso(caso), //output [54:0] caso
        .a0(a0), //input [17:0] a0
        .b0(b0), //input [17:0] b0
        .a1(a1), //input [17:0] a1
        .b1(b1), //input [17:0] b1
        .ce(ce), //input ce
        .clk(clk), //input clk
        .reset(reset) //input reset
    );

//--------Copy end-------------------
