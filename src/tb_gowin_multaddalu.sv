`timescale 1ns/1ns

module tb_gowin_multaddalu;
    timeunit 1ns;
    timeprecision 1ns;

    reg clk, ce, reset;
    reg [17:0] a0, b0, a1, b1;
    wire [36:0] dout;
    wire [54:0] caso;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    Gowin_MULTADDALU dut (
        .clk(clk),
        .ce(ce),
        .reset(reset),
        .a0(a0),
        .b0(b0),
        .a1(a1),
        .b1(b1),
        .dout(dout),
        .caso(caso)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Test procedure
    initial begin
        reg [17:0] rand_a0, rand_b0, rand_a1, rand_b1;
        reg signed [37:0] expected; // Signed 38-bit to avoid overflow
        $display("Starting MULTADDALU test with 1000 test cases");
        reset = 1; ce = 0;
        a0 = 0; b0 = 0; a1 = 0; b1 = 0;
        #2116.4; // 10 cycles (211.64 ns) for reset
        @(negedge clk);
        reset = 0; ce = 1;

        repeat(1000) begin
            @(negedge clk);
            // Random signed inputs (reduced range to avoid overflow)
            rand_a0 = $urandom_range(0, 2**16-1) - 2**15; // -32,768 to 32,767
            rand_b0 = $urandom_range(0, 2**16-1) - 2**15;
            rand_a1 = $urandom_range(0, 2**16-1) - 2**15;
            rand_b1 = $urandom_range(0, 2**16-1) - 2**15;
            a0 = rand_a0; b0 = rand_b0; a1 = rand_a1; b1 = rand_b1;
            #423.28; // 4 cycles: input registers, computation, output register, safety
            expected = ($signed(rand_a0) * $signed(rand_b0)) + ($signed(rand_a1) * $signed(rand_b1));
            if (dout == expected[36:0]) begin
                pass_count = pass_count + 1;
            end else begin
                $display("Test %0d: dout=%0d, expected=%0d (a0=%0d, b0=%0d, a1=%0d, b1=%0d)", 
                         test_count, dout, expected[36:0], rand_a0, rand_b0, rand_a1, rand_b1);
            end
            test_count = test_count + 1;
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