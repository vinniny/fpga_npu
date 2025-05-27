`timescale 100ps/100ps

module tb_gowin_rpll;
    timeunit 100ps;
    timeprecision 100ps;

    reg clkin;
    wire clkout, lock;
    integer lock_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    Gowin_rPLL dut (
        .clkin(clkin),
        .clkout(clkout),
        .lock(lock)
    );

    // Clock generation: 27 MHz (37.037 ns)
    initial begin
        clkin = 0;
        forever #185.185 clkin = ~clkin;
    end

    // Test procedure
    initial begin
        real t1, period;
        $display("Starting rPLL test with 1000 test cases");
        repeat(1000) begin
            @(negedge clkin);
            #1000; // 100 ns reset pulse
            wait(lock == 1 || $time > 1000000); // Wait up to 100 us
            if (lock == 1) begin
                lock_count = lock_count + 1;
                $display("Test %0d: Lock achieved at %t", test_count, $time);
                // Verify clkout frequency (~21.164 ns period)
                @(posedge clkout);
                t1 = $realtime;
                @(posedge clkout);
                period = ($realtime - t1) / 10.0; // Convert to ns
                if (period < 21.0 || period > 21.3) begin
                    $display("Test %0d: clkout period %0.3f ns out of range (21.0–21.3 ns)", test_count, period);
                end
            end else begin
                $display("Test %0d: Lock failed", test_count);
            end
            test_count = test_count + 1;
            #10000; // 1 us between tests
        end
        $display("Test completed: %0d/1000 locks achieved", lock_count);
        $finish;
    end

    // Timeout
    initial begin
        #2000000; // 200 us total timeout
        $display("Simulation timeout");
        $finish;
    end
endmodule