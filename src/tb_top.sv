module tb_top;
    logic clk, rst_n, sclk, mosi, cs_n, miso, done;

    top dut (
        .clk(clk), .rst_n(rst_n), .sclk(sclk), .mosi(mosi), .cs_n(cs_n),
        .miso(miso), .done(done)
    );

    initial begin
        clk = 0; sclk = 0;
        forever begin
            #18.52 clk = ~clk; // 27 MHz (37.04 ns period)
            #10 sclk = ~sclk;  // 50 MHz (20 ns period)
        end
    end

    initial begin
        rst_n = 0; cs_n = 1; mosi = 0;
        #100 rst_n = 1;
        #100 cs_n = 0;
        // Send SPI command (cmd = 8'h02, start)
        for (int i = 0; i < 24; i++) begin
            mosi = (i == 0) ? 1 : 0; // cmd = 8'h02
            #20;
        end
        cs_n = 1;
        #1000;
        if (done) $display("Top: Done signal asserted");
        else $display("Top: Done signal not asserted");
        $finish;
    end
endmodule