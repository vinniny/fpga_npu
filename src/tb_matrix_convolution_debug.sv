`timescale 1ns/1ns

module tb_matrix_convolution_debug;
    timeunit 1ns;
    timeprecision 1ns;

    // Signals
    logic clk, rst_n, start;
    logic signed [7:0] input_tile [0:5][0:5];
    logic signed [7:0] kernel [0:2][0:2];
    logic signed [15:0] c [0:3][0:3];
    logic signed [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    logic signed [36:0] dsp_out [0:4];
    logic dsp_ce, done;
    integer pass_count = 0;
    integer test_count = 0;

    // Global Signal Reset
    GSR GSR(.GSRI(1'b1));

    // DUT Instantiation
    matrix_convolution dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .input_tile(input_tile), .kernel(kernel),
        .c(c), .dsp_a0(dsp_a0), .dsp_b0(dsp_b0),
        .dsp_out(dsp_out), .dsp_ce(dsp_ce), .done(done)
    );

    // Gowin DSP Instantiation
    genvar z;
    generate
        for (z = 0; z < 5; z++) begin : gen_dsp
            Gowin_MULTADDALU dsp_inst (
                .a0(dsp_a0[z]), .b0(dsp_b0[z]), .a1(18'd0), .b1(18'd0),
                .dout(dsp_out[z]), .caso(), .ce(dsp_ce), .clk(clk), .reset(~rst_n)
            );
        end
    endgenerate

    // Clock Generation (47.25 MHz)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Clocking Block for Synchronization
    clocking cb @(posedge clk);
        output rst_n, start;
        input done, c, dsp_ce;
    endclocking

    // Test Procedure
    initial begin
        integer i, j, m, n;
        logic signed [15:0] expected [0:3][0:3];
        $display("Starting matrix_convolution test with 1000 test cases");

        // Initialize signals
        rst_n = 0;
        start = 0;
        for (i = 0; i < 6; i++)
            for (j = 0; j < 6; j++)
                input_tile[i][j] = 0;
        for (i = 0; i < 3; i++)
            for (j = 0; j < 3; j++)
                kernel[i][j] = 0;

        // Reset
        repeat(20) @(cb);
        $display("Reset deasserted at time %0t", $time);
        cb.rst_n <= 1;
        @(cb);

        // Run 1000 tests
        repeat(1000) begin
            // Generate random inputs
            for (i = 0; i < 6; i++)
                for (j = 0; j < 6; j++)
                    input_tile[i][j] = $urandom_range(-128, 127);
            for (i = 0; i < 3; i++)
                for (j = 0; j < 3; j++)
                    kernel[i][j] = $urandom_range(-128, 127);

            // Compute expected outputs
            for (i = 0; i < 4; i++)
                for (j = 0; j < 4; j++) begin
                    expected[i][j] = 0;
                    for (m = 0; m < 3; m++)
                        for (n = 0; n < 3; n++)
                            expected[i][j] += $signed(input_tile[i+m][j+n]) * $signed(kernel[m][n]);
                end

            // Start convolution
            $display("Test %0d: Start asserted at time %0t", test_count, $time);
            cb.start <= 1;
            repeat(4) @(cb);
            cb.start <= 0;
            $display("Test %0d: Start deasserted at time %0t", test_count, $time);

            // Wait for completion
            wait(cb.done == 1 || $time > ($time + 100000)); // 10 µs timeout
            if (cb.done != 1) begin
                $display("Test %0d: Timeout at time %0t, computing=%0b, start_reg=%0b, mul_count=%0d, m=%0d, n=%0d",
                         test_count, $time, dut.computing, dut.start_reg, dut.mul_count, dut.m, dut.n);
                $finish;
            end

            // Stabilize outputs
            repeat(10) @(cb);

            // Verify outputs
            for (i = 0; i < 4; i++)
                for (j = 0; j < 4; j++) begin
                    if (cb.c[i][j] != expected[i][j]) begin
                        $display("Test %0d: c[%0d][%0d]=%0d, expected=%0d at time %0t, computing=%0b, start_reg=%0b, mul_count=%0d, m=%0d, n=%0d",
                                 test_count, i, j, cb.c[i][j], expected[i][j], $time, dut.computing, dut.start_reg, dut.mul_count, dut.m, dut.n);
                        $finish;
                    end else begin
                        pass_count++;
                    end
                end

            // Inter-test reset
            cb.rst_n <= 0;
            repeat(4) @(cb);
            cb.rst_n <= 1;
            test_count++;
            repeat(10) @(cb); // 1 µs gap
        end

        $display("Test completed: %0d/16000 checks passed", pass_count);
        $finish;
    end

    // Global Timeout
    initial begin
        #20ms;
        $display("Simulation timeout");
        $finish;
    end
endmodule