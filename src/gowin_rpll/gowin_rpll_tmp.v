//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.11.02 (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Sat May 24 00:38:52 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_rPLL_100mhz your_instance_name(
        .clkout(clkout), //output clkout
        .lock(lock), //output lock
        .clkin(clkin) //input clkin
    );

//--------Copy end-------------------
