`timescale 1ns/1ns

module tb_matrix_dot;
    timeunit 1ns;
    timeprecision 1ns;

    logic clk, rst_n, start;
    logic [127:0] a, b; // Packed 128-bit
    logic [31:0] c; // 32-bit output
    logic done;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    // DUT
    matrix_dot dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .a(a), .b(b), .c(c), .done(done)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Clocking block
    clocking cb @(posedge clk);
        output rst_n, start;
        input done, c;
    endclocking

    // Waveform logging
    initial begin
        $dumpfile("matrix_dot.vcd");
        $dumpvars(0, tb_matrix_dot);
    end

    // Test procedure
    initial begin
        integer i;
        logic [31:0] expected;
        logic [7:0] a_unpacked [0:15], b_unpacked [0:15];
        $display("Starting matrix_dot test with 1000 test cases");

        // Initialize
        cb.rst_n <= 0;
        cb.start <= 0;
        a = 0;
        b = 0;
        repeat(20) @(cb);
        cb.rst_n <= 1;
        @(cb);

        // Run 1000 tests
        repeat(1000) begin
            // Random inputs
            for (i = 0; i < 16; i++) begin
                a_unpacked[i] = $urandom_range(0, 255);
                b_unpacked[i] = $urandom_range(0, 255);
            end
            // Pack inputs
            for (i = 0; i < 16; i++) begin
                a[i*8 +: 8] = a_unpacked[i];
                b[i*8 +: 8] = b_unpacked[i];
            end

            // Start
            $display("Test %0d: Start asserted at time %0t", test_count, $time);
            cb.start <= 1;
            repeat(4) @(cb);
            cb.start <= 0;
            $display("Test %0d: Start deasserted at time %0t", test_count, $time);

            // Wait for done
            wait(cb.done == 1 || $time > ($time + 10000));
            if (cb.done != 1) begin
                $display("Test %0d: Timeout at time %0t, computing=%0b, i=%0d, sum=%0d", 
                         test_count, $time, dut.computing, dut.i, dut.sum);
                $finish;
            end

            // Stabilize output
            @(cb);

            // Verify
            expected = 0;
            for (i = 0; i < 16; i++)
                expected += a_unpacked[i] * b_unpacked[i];
            if (cb.c != expected) begin
                $display("Test %0d: c=%0d, expected=%0d at time %0t, sum=%0d", 
                         test_count, cb.c, expected, $time, dut.sum);
                $finish;
            end else begin
                pass_count++;
            end

            // Inter-test reset
            cb.rst_n <= 0;
            repeat(4) @(cb);
            cb.rst_n <= 1;
            test_count++;
            repeat(10) @(cb);
        end

        $display("Test completed: %0d/1000 passed", pass_count);
        $finish;
    end

    // Global timeout
    initial begin
        #20ms;
        $display("Simulation timeout");
        $finish;
    end
endmodule