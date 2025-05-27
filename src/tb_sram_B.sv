`timescale 100ps/100ps

module tb_sram_B;
    timeunit 100ps;
    timeprecision 100ps;

    logic sram_B_we, rpll_clk;
    logic [7:0] sram_B_din, sram_B_dout;
    logic [9:0] sram_B_addr;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    sram_B dut (
        .sram_B_we(sram_B_we), .rpll_clk(rpll_clk), .sram_B_din(sram_B_din),
        .sram_B_addr(sram_B_addr), .sram_B_dout(sram_B_dout)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        rpll_clk = 0;
        forever #105.82 rpll_clk = ~rpll_clk;
    end

    // Test procedure
    initial begin
        $display("Starting sram_B test with 1000 test cases");
        sram_B_we = 0; sram_B_din = 8'h00; sram_B_addr = 10'd0;
        #1000; // 100 ns reset

        repeat(1000) begin
            @(negedge rpll_clk);
            // Random write
            sram_B_we = 1;
            sram_B_din = $urandom_range(0, 255);
            sram_B_addr = $urandom_range(0, 1023);
            #211.64; // 2 cycles
            sram_B_we = 0;
            // Read back
            #211.64;
            assert(sram_B_dout == sram_B_din)
                else $error("Test %0d: addr=%0d, read=%h, expected=%h", test_count, sram_B_addr, sram_B_dout, sram_B_din);
            if (sram_B_dout == sram_B_din) pass_count++;
            test_count++;
            #1000; // 100 ns between tests
        end
        $display("Test completed: %0d/1000 passed", pass_count);
        $finish;
    end

    // Timeout
    initial begin
        #1000000; // 100 us
        $display("Simulation timeout");
        $finish;
    end
endmodule