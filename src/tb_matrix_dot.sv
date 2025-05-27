`timescale 100ps/100ps

module tb_matrix_dot;
    timeunit 100ps;
    timeprecision 100ps;

    reg clk, rst_n, start;
    reg [7:0] a [0:15], b [0:15];
    wire [15:0] c;
    wire done;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    matrix_dot dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .c(c),
        .done(done)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Test procedure
    initial begin
        integer i;
        reg [15:0] expected;
        $display("Starting matrix_dot test with 1000 test cases");
        rst_n = 0; start = 0;
        for (i = 0; i < 16; i = i + 1) begin
            a[i] = 0; b[i] = 0;
        end
        #1000; // 100 ns reset
        rst_n = 1;

        repeat(1000) begin
            @(negedge clk);
            // Random inputs
            for (i = 0; i < 16; i = i + 1) begin
                a[i] = $urandom_range(0, 255);
                b[i] = $urandom_range(0, 255);
            end
            start = 1;
            #211.64; // 2 cycles
            start = 0;
            wait(done == 1);
            // Verify dot product
            expected = 0;
            for (i = 0; i < 16; i = i + 1)
                expected = expected + a[i] * b[i];
            if (c != expected) begin
                $display("Test %0d: c=%0d, expected=%0d", test_count, c, expected);
            end else begin
                pass_count = pass_count + 1;
            end
            test_count = test_count + 1;
            #10000; // 1 us between tests
        end
        $display("Test completed: %0d/1000 passed", pass_count);
        $finish;
    end

    // Timeout
    initial begin
        #10000000; // 1 ms
        $display("Simulation timeout");
        $finish;
    end
endmodule