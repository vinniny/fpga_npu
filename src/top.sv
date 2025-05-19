module top (
    input logic clk, rst_n, sclk, mosi, cs_n,
    output logic miso, done
);
//    logic clk_100mhz;
 //   rPLL pll_inst (
 //       .clkin(clk),      // 27 MHz input
//        .clkout(clk_100mhz), // 100 MHz output
//        .reset(~rst_n)
//    );

    top_npu_system npu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .miso(miso),
        .done(done)
    );
endmodule