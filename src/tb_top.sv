`timescale 100ps/100ps

module tb_top;
    timeunit 100ps;
    timeprecision 100ps;

    logic clk, rst_n, sclk, mosi, cs_n, miso, done;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    top dut (
        .clk(clk), .rst_n(rst_n), .sclk(sclk), .mosi(mosi), .cs_n(cs_n),
        .miso(miso), .done(done)
    );

    // Clocks: clk (27 MHz, 37.037 ns), sclk (50 MHz, 20 ns)
    initial begin
        clk = 0; sclk = 0;
        forever begin
            #185.185 clk = ~clk;
            #100 sclk = ~sclk;
        end
    end

    // Test procedure
    initial begin
        integer i;
        reg [7:0] cmd;
        reg [23:0] spi_data;
        $display("Starting top test with 1000 test cases");
        rst_n = 0; cs_n = 1; mosi = 0;
        #1000; // 100 ns reset
        rst_n = 1;

        repeat(1000) begin
            @(negedge sclk);
            cs_n = 0;
            // Random SPI command
            cmd = $urandom_range(0, 255);
            spi_data = {cmd, 16'h0000}; // Simplified
            // Send SPI data
            for (i = 23; i >= 0; i = i - 1) begin
                mosi = spi_data[i];
                #200; // 20 ns per bit
            end
            cs_n = 1;
            wait(done == 1 || $time > ($realtime + 100000)); // 10 us timeout
            if (done == 1) begin
                pass_count = pass_count + 1;
                $display("Test %0d: Done signal asserted for cmd=%h", test_count, cmd);
            end else begin
                $display("Test %0d: Done signal not asserted for cmd=%h", test_count, cmd);
            end
            test_count = test_count + 1;
            #10000; // 1 us between tests
        end
        $display("Test completed: %0d/1000 passed", pass_count);
        $finish;
    end

    // Timeout
    initial begin
        #100000000; // 10 ms
        $display("Simulation timeout");
        $finish;
    end
endmodule