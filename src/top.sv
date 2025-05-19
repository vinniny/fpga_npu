module top (
    input clk, rst_n, sclk, mosi, cs_n,
    output miso, done
);
    top_npu_system npu_inst (
        .clk(clk), .rst_n(rst_n), .sclk(sclk), .mosi(mosi), .cs_n(cs_n),
        .miso(miso), .done(done)
    );
endmodule