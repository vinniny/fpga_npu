`timescale 100ps/100ps

module tb_matrix_convolution;
    timeunit 100ps;
    timeprecision 100ps;

    reg clk, rst_n, start;
    reg signed [7:0] input_tile [0:5][0:5];
    reg signed [7:0] kernel [0:2][0:2];
    wire signed [15:0] c [0:3][0:3];
    wire signed [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    reg signed [36:0] dsp_out [0:4];
    wire dsp_ce, done;

    GSR GSR(.GSRI(1'b1));

    matrix_convolution dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .input_tile(input_tile), .kernel(kernel),
        .c(c), .dsp_a0(dsp_a0), .dsp_b0(dsp_b0),
        .dsp_out(dsp_out), .dsp_ce(dsp_ce), .done(done)
    );

    // DSP delay arrays in module scope
    reg signed [17:0] dsp_a0_dly [0:4][0:2], dsp_b0_dly [0:4][0:2];

    initial begin
        clk = 0;
        forever #105.82 clk = ~clk; // 47.25 MHz
    end

    // DSP emulation with 3-cycle latency in module scope
    always @(posedge clk) begin
        if (rst_n) begin
            if (dsp_ce) begin
                for (int i = 0; i < 5; i++) begin
                    dsp_a0_dly[i][0] <= dsp_a0[i];
                    dsp_a0_dly[i][1] <= dsp_a0_dly[i][0];
                    dsp_a0_dly[i][2] <= dsp_a0_dly[i][1];
                    dsp_b0_dly[i][0] <= dsp_b0[i];
                    dsp_b0_dly[i][1] <= dsp_b0_dly[i][0];
                    dsp_b0_dly[i][2] <= dsp_b0_dly[i][1];
                    dsp_out[i] <= $signed(dsp_a0_dly[i][2][7:0]) * $signed(dsp_b0_dly[i][2][7:0]);
                    if ((dsp_a0_dly[i][2] == 0 && dsp_b0_dly[i][2] != 0) || (dsp_b0_dly[i][2] == 0 && dsp_a0_dly[i][2] != 0)) begin
                        $display("Error: Test %0d: dsp_a0_dly[%0d][2]=%0d, dsp_b0_dly[%0d][2]=%0d at time %0t", test_count, i, dsp_a0_dly[i][2], i, dsp_b0_dly[i][2], $time);
                        $finish;
                    end
                end
            end else begin
                for (int i = 0; i < 5; i++) begin
                    dsp_a0_dly[i][0] <= 0;
                    dsp_a0_dly[i][1] <= 0;
                    dsp_a0_dly[i][2] <= 0;
                    dsp_b0_dly[i][0] <= 0;
                    dsp_b0_dly[i][1] <= 0;
                    dsp_b0_dly[i][2] <= 0;
                    dsp_out[i] <= 0;
                end
            end
        end else begin
            // Reset state
            for (int i = 0; i < 5; i++) begin
                dsp_a0_dly[i][0] <= 0;
                dsp_a0_dly[i][1] <= 0;
                dsp_a0_dly[i][2] <= 0;
                dsp_b0_dly[i][0] <= 0;
                dsp_b0_dly[i][1] <= 0;
                dsp_b0_dly[i][2] <= 0;
                dsp_out[i] <= 0;
            end
        end
    end

    module testbench;
        integer pass_count = 0;
        integer test_count = 0;

        // Clocking block for synchronization
        clocking cb @(posedge clk);
            output rst_n, start;
            input done, c, dsp_ce;
        endclocking

        initial begin
            integer i, j, m, n;
            reg signed [15:0] expected [0:3][0:3];
            $display("Starting matrix_convolution test with 1000 test cases");
            cb.rst_n <= 0; cb.start <= 0;
            for (i = 0; i < 6; i++)
                for (j = 0; j < 6; j++)
                    input_tile[i][j] = 0;
            for (i = 0; i < 3; i++)
                for (j = 0; j < 3; j++)
                    kernel[i][j] = 0;
            for (i = 0; i < 5; i++)
                dsp_out[i] = 0;
            repeat(20) @(cb); // 20 cycles reset
            $display("Reset deasserted at time %0t", $time);
            cb.rst_n <= 1;
            @(cb); // Stabilize reset

            repeat(1000) begin
                // Random inputs
                for (i = 0; i < 6; i++)
                    for (j = 0; j < 6; j++)
                        input_tile[i][j] = $urandom_range(-128, 127);
                for (i = 0; i < 3; i++)
                    for (j = 0; j < 3; j++)
                        kernel[i][j] = $urandom_range(-128, 127);
                // Compute expected values
                for (i = 0; i < 4; i++)
                    for (j = 0; j < 4; j++) begin
                        expected[i][j] = 0;
                        for (m = 0; m < 3; m++)
                            for (n = 0; n < 3; n++)
                                expected[i][j] += $signed(input_tile[i+m][j+n]) * $signed(kernel[m][n]);
                    end
                $display("Test %0d: Start asserted at time %0t", test_count, $time);
                cb.start <= 1;
                repeat(4) @(cb); // 4 cycles for start pulse
                cb.start <= 0;
                $display("Test %0d: Start deasserted at time %0t", test_count, $time);
                wait(cb.done == 1 || $time > ($time + 100000)); // 10 µs timeout
                if (cb.done != 1) begin
                    $display("Test %0d: timeout, done not asserted at time %0t, computing=%0b, start_reg=%0b, mul_count=%0d, m=%0d, n=%0d", test_count, $time, dut.computing, dut.start_reg, dut.mul_count, dut.m, dut.n);
                    $finish;
                end
                repeat(10) @(cb); // 10 cycles for output stabilization
                // Verify outputs
                for (i = 0; i < 4; i++)
                    for (j = 0; j < 4; j++) begin
                        if (cb.c[i][j] != expected[i][j]) begin
                            $display("Test %0d: c[%0d][%0d]=%0d, expected=%0d at time %0t, computing=%0b, start_reg=%0b, mul_count=%0d, m=%0d, n=%0d", test_count, i, j, cb.c[i][j], expected[i][j], $time, dut.computing, dut.start_reg, dut.mul_count, dut.m, dut.n);
                            $finish;
                        end else begin
                            pass_count++;
                        end
                    end
                // Inter-test reset
                cb.rst_n <= 0;
                repeat(4) @(cb); // 4 cycles reset
                cb.rst_n <= 1;
                test_count++;
                repeat(10) @(cb); // 1 µs between tests
            end
            $display("Test completed: %0d/16000 checks passed", pass_count);
            $finish;
        end

        // Global timeout
        initial begin
            #20ms; // 20 ms
            $display("Simulation timeout");
            $finish;
        end
    endmodule
endmodule