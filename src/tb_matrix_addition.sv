`timescale 100ps/100ps

module tb_matrix_addition;
    timeunit 100ps;
    timeprecision 100ps;

    logic clk, rst_n, start, done;
    logic [7:0] a [0:3][0:3], b [0:3][0:3];
    logic [15:0] c [0:3][0:3];
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    matrix_addition dut (
        .clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b), .c(c), .done(done)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Test procedure
    initial begin
        integer i, j;
        reg [15:0] expected [0:3][0:3];
        $display("Starting matrix_addition test with 1000 test cases");
        rst_n = 0; start = 0;
        for (i = 0; i < 4; i++)
            for (j = 0; j < 4; j++) begin
                a[i][j] = 0; b[i][j] = 0;
            end
        #4232.8; // 20 cycles reset
        @(negedge clk);
        rst_n = 1;

        repeat(1000) begin
            @(negedge clk);
            // Random inputs
            for (i = 0; i < 4; i++)
                for (j = 0; j < 4; j++) begin
                    a[i][j] = $urandom_range(0, 255);
                    b[i][j] = $urandom_range(0, 255);
                end
            start = 1;
            #211.64; // 2 cycles
            start = 0;
            wait(done == 1 || $time > ($time + 50000)); // 5 us timeout
            if (done != 1) $display("Test %0d: done did not assert", test_count);
            #634.92; // 6 cycles for output stabilization
            for (i = 0; i < 4; i++)
                for (j = 0; j < 4; j++) begin
                    expected[i][j] = a[i][j] + b[i][j];
                    if (c[i][j] != expected[i][j]) begin
                        $display("Test %0d: c[%0d][%0d]=%0d, expected=%0d (a=%0d, b=%0d)", 
                                 test_count, i, j, c[i][j], expected[i][j], a[i][j], b[i][j]);
                    end else begin
                        pass_count++;
                    end
                end
            // Extended reset between tests
            rst_n = 0;
            #423.28; // 4 cycles reset
            rst_n = 1;
            test_count++;
            #10000; // 1 us between tests
        end
        $display("Test completed: %0d/16000 checks passed", pass_count);
        $finish;
    end

    // Timeout
    initial begin
        #30000000; // 3 ms
        $display("Simulation timeout");
        $finish;
    end
endmodule