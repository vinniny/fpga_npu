`timescale 100ps/100ps

module tb_sram_C;
    timeunit 100ps;
    timeprecision 100ps;

    logic sram_C_we, rpll_clk;
    logic [7:0] sram_C_din, sram_C_dout;
    logic [9:0] sram_C_addr;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    sram_C dut (
        .sram_C_we(sram_C_we), .rpll_clk(rpll_clk), .sram_C_din(sram_C_din),
        .sram_C_addr(sram_C_addr), .sram_C_dout(sram_C_dout)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        rpll_clk = 0;
        forever #105.82 rpll_clk = ~rpll_clk;
    end

    // Test procedure
    initial begin
        $display("Starting sram_C test with 1000 test cases");
        sram_C_we = 0; sram_C_din = 8'h00; sram_C_addr = 10'd0;
        #1000; // 100 ns reset

        repeat(1000) begin
            @(negedge rpll_clk);
            // Random write
            sram_C_we = 1;
            sram_C_din = $urandom_range(0, 255);
            sram_C_addr = $urandom_range(0, 1023);
            #211.64; // 2 cycles
            sram_C_we = 0;
            // Read back
            #211.64;
            assert(sram_C_dout == sram_C_din)
                else $error("Test %0d: addr=%0d, read=%h, expected=%h", test_count, sram_C_addr, sram_C_dout, sram_C_din);
            if (sram_C_dout == sram_C_din) pass_count++;
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