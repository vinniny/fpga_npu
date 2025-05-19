//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.11.01 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Tue May 13 12:27:04 2025

module Gowin_MULTADDALU (dout, caso, a0, b0, a1, b1, ce, clk, reset);

output [36:0] dout;
output [54:0] caso;
input [17:0] a0;
input [17:0] b0;
input [17:0] a1;
input [17:0] b1;
input ce;
input clk;
input reset;

wire [16:0] dout_w;
wire [17:0] soa_w;
wire [17:0] sob_w;
wire gw_vcc;
wire gw_gnd;

assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

MULTADDALU18X18 multaddalu18x18_inst (
    .DOUT({dout_w[16:0],dout[36:0]}),
    .CASO(caso),
    .SOA(soa_w),
    .SOB(sob_w),
    .C({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .A0(a0),
    .B0(b0),
    .A1(a1),
    .B1(b1),
    .ASIGN({gw_vcc,gw_vcc}),
    .BSIGN({gw_vcc,gw_vcc}),
    .CASI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .ACCLOAD(gw_gnd),
    .SIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .SIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .CE(ce),
    .CLK(clk),
    .RESET(reset),
    .ASEL({gw_gnd,gw_gnd}),
    .BSEL({gw_gnd,gw_gnd})
);

defparam multaddalu18x18_inst.A0REG = 1'b1;
defparam multaddalu18x18_inst.B0REG = 1'b1;
defparam multaddalu18x18_inst.A1REG = 1'b1;
defparam multaddalu18x18_inst.B1REG = 1'b1;
defparam multaddalu18x18_inst.CREG = 1'b0;
defparam multaddalu18x18_inst.PIPE0_REG = 1'b0;
defparam multaddalu18x18_inst.PIPE1_REG = 1'b0;
defparam multaddalu18x18_inst.OUT_REG = 1'b1;
defparam multaddalu18x18_inst.ASIGN0_REG = 1'b0;
defparam multaddalu18x18_inst.ASIGN1_REG = 1'b0;
defparam multaddalu18x18_inst.ACCLOAD_REG0 = 1'b0;
defparam multaddalu18x18_inst.ACCLOAD_REG1 = 1'b0;
defparam multaddalu18x18_inst.BSIGN0_REG = 1'b0;
defparam multaddalu18x18_inst.BSIGN1_REG = 1'b0;
defparam multaddalu18x18_inst.SOA_REG = 1'b0;
defparam multaddalu18x18_inst.B_ADD_SUB = 1'b0;
defparam multaddalu18x18_inst.C_ADD_SUB = 1'b0;
defparam multaddalu18x18_inst.MULTADDALU18X18_MODE = 1;
defparam multaddalu18x18_inst.MULT_RESET_MODE = "SYNC";

endmodule //Gowin_MULTADDALU
