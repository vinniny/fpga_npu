`timescale 100ps/100ps

module tb_matrix_subtraction;
    timeunit 100ps;
    timeprecision 100ps;

    logic clk, rst_n, start, done;
    logic [7:0] a [0:3][0:3], b [0:3][0:3];
    logic [15:0] c [0:3][0:3];
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    matrix_subtraction dut (
        .clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b), .c(c), .done(done)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Test procedure
    initial begin
        $display("Starting matrix_subtraction test with 1000 test cases");
        rst_n = 0; start = 0;
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++) begin
                a[i][j] = 0; b[i][j] = 0;
            end
        #1000; // 100 ns reset
        rst_n = 1;

        repeat(1000) begin
            @(negedge clk);
            // Random inputs
            for (int i = 0; i < 4; i++)
                for (int j = 0; j < 4; j++) begin
                    a[i][j] = $urandom_range(0, 255);
                    b[i][j] = $urandom_range(0, a[i][j]); // Ensure non-negative result
                end
            start = 1;
            @(negedge clk);
            start = 0;
            wait(done == 1 || $time > $realtime + 20000); // 2 us timeout
            if (done == 1) begin
                for (int i = 0; i < 4; i++)
                    for (int j = 0; j < 4; j++) begin
                        automatic logic [15:0] expected = a[i][j] - b[i][j];
                        assert(c[i][j] == expected)
                            else $display("Test %0d: c[%0d][%0d]=%0d, a=%0d, b=%0d, expected=%0d", test_count, i, j, c[i][j], a[i][j], b[i][j], expected);
                        if (c[i][j] == expected) pass_count++;
                    end
            end else begin
                $display("Test %0d: Failed to complete", test_count);
            end
            test_count++;
            #10000; // 1 us between tests
        end
        $display("Test completed: %0d/16000 checks passed", pass_count);
        $finish;
    end

    // Timeout
    initial begin
        #20000000; // 2 ms
        $display("Simulation timeout");
        $finish;
    end
endmodule