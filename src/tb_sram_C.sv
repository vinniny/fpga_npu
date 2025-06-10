`timescale 1ns/1ns

module tb_sram_C;
    timeunit 1ns;
    timeprecision 1ns;

    logic we, ce, clk;
    logic [7:0] din, dout;
    logic [9:0] addr;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    sram_C dut (
        .clk(clk), .ce(ce), .we(we), .addr(addr), .din(din), .dout(dout)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Test procedure
    initial begin
        $display("Starting sram_A test with 1000 test cases");
        ce = 0; we = 0; din = 8'h00; addr = 10'd0;
        #1000; // 100 ns reset

        // Check initialization
        ce = 1; we = 0; addr = 10'd0;
        #211.64;
        assert(dout == 8'h00) else $error("Init check failed: dout=%h, expected=00", dout);
        ce = 0;

        repeat(1000) begin
            @(negedge clk);
            // Random write
            ce = 1; we = 1;
            din = $urandom_range(0, 255);
            addr = $urandom_range(0, 1023);
            #211.64; // 2 cycles
            we = 0;
            // Read back
            #211.64;
            assert(dout == din)
                else $error("Test %0d: addr=%0d, read=%h, expected=%h", test_count, addr, dout, din);
            if (dout == din) pass_count++;
            test_count++;
            ce = 0;
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