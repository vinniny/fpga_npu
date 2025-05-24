module tb_top_npu_system;
    logic clk, rst_n, sclk, mosi, cs_n, miso, done;

    top_npu_system dut (
        .clk(clk), .rst_n(rst_n), .sclk(sclk), .mosi(mosi), .cs_n(cs_n),
        .miso(miso), .done(done)
    );

    initial begin
        clk = 0; sclk = 0;
        forever begin
            #10.58 clk = ~clk; // 47.25 MHz (21.164 ns period)
            #10 sclk = ~sclk;  // 50 MHz (20 ns period)
        end
    end

    initial begin
        rst_n = 0; cs_n = 1; mosi = 0;
        #100 rst_n = 1;
        #100 cs_n = 0;
        // Send SPI command (cmd = 8'h01, tile_i = 3'd0, tile_j = 3'd0, op_code = 3'd0, data_in = 8'hAA)
        for (int i = 23; i >= 0; i--) begin
            mosi = (i == 23 || i == 7) ? 1 : (i >= 0 && i <= 6) ? (8'hAA >> (7-i)) : 0;
            #20;
        end
        cs_n = 1;
        #1000;
        if (done) $display("Top NPU: Done signal asserted");
        else $display("Top NPU: Done signal not asserted");
        $finish;
    end
endmodule