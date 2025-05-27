`timescale 100ps/100ps

module tb_matrix_multiplier;
    timeunit 100ps;
    timeprecision 100ps;

    logic clk, rst_n, start, dsp_ce, done;
    logic [7:0] a [0:3][0:15], b [0:15][0:3];
    logic [15:0] c [0:3][0:3];
    logic [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    logic [36:0] dsp_out [0:4];
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    matrix_multiplier dut (
        .clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b), .c(c),
        .dsp_a0(dsp_a0), .dsp_b0(dsp_b0), .dsp_out(dsp_out), .dsp_ce(dsp_ce), .done(done)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Simulate DSP output
    always_comb begin
        for (int z = 0; z < 5; z++)
            dsp_out[z] = dsp_ce ? {19'd0, dsp_a0[z][7:0] * dsp_b0[z][7:0]} : 0;
    end

    // Test procedure
    initial begin
        $display("Starting matrix_multiplier test with 1000 test cases");
        rst_n = 0; start = 0;
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 16; j++) begin
                a[i][j] = 0; b[j][i] = 0;
            end
        #1000; // 100 ns reset
        rst_n = 1;

        repeat(1000) begin
            @(negedge clk);
            // Random inputs
            for (int i = 0; i < 4; i++)
                for (int j = 0; j < 16; j++) begin
                    a[i][j] = $urandom_range(0, 255);
                    b[j][i] = $urandom_range(0, 255);
                end
            start = 1;
            #211.64; // 2 cycles
            start = 0;
            wait(done == 1 || $time > $realtime + 100000); // 10 us timeout
            if (done == 1) begin
                for (int i = 0; i < 4; i++)
                    for (int j = 0; j < 4; j++) begin
                        automatic logic [15:0] expected = 0;
                        for (int k = 0; k < 16; k++)
                            expected += a[i][k] * b[k][j];
                        assert(c[i][j] == expected)
                            else $error("Test %0d: c[%0d][%0d]=%0d, expected=%0d", test_count, i, j, c[i][j], expected);
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
        #10000000; // 1 ms
        $display("Simulation timeout");
        $finish;
    end
endmodule