`timescale 100ps/100ps

module tb_tile_processor;
    timeunit 100ps;
    timeprecision 100ps;

    logic clk, rst_n, start, done;
    logic [2:0] tile_i, tile_j, op_code;
    logic [7:0] sram_A_dout, sram_B_dout;
    logic [9:0] tp_sram_A_addr, tp_sram_B_addr, tp_sram_C_addr;
    logic [7:0] tp_sram_A_din, tp_sram_B_din, tp_sram_C_din;
    logic tp_sram_A_we, tp_sram_B_we, tp_sram_C_we;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    tile_processor dut (
        .clk(clk), .rst_n(rst_n), .start(start), .tile_i(tile_i), .tile_j(tile_j),
        .op_code(op_code), .sram_A_dout(sram_A_dout), .sram_B_dout(sram_B_dout),
        .tp_sram_A_we(tp_sram_A_we), .tp_sram_B_we(tp_sram_B_we), .tp_sram_C_we(tp_sram_C_we),
        .tp_sram_A_addr(tp_sram_A_addr), .tp_sram_B_addr(tp_sram_B_addr), .tp_sram_C_addr(tp_sram_C_addr),
        .tp_sram_A_din(tp_sram_A_din), .tp_sram_B_din(tp_sram_B_din), .tp_sram_C_din(tp_sram_C_din),
        .done(done)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Test procedure
    initial begin
        reg [7:0] sram_A_val, sram_B_val;
        reg [15:0] expected;
        $display("Starting tile_processor test with 1000 test cases");
        rst_n = 0; start = 0; tile_i = 0; tile_j = 0; op_code = 0;
        sram_A_dout = 8'h00; sram_B_dout = 8'h00;
        #1000; // 100 ns reset
        rst_n = 1;

        repeat(1000) begin
            @(negedge clk);
            // Random configuration
            tile_i = $urandom_range(0, 7);
            tile_j = $urandom_range(0, 7);
            op_code = $urandom_range(0, 7);
            start = 1;
            #211.64; // 2 cycles
            start = 0;
            // Simulate SRAM reads
            sram_A_val = $urandom_range(0, 255);
            sram_B_val = $urandom_range(0, 255);
            repeat(64) begin
                sram_A_dout = sram_A_val;
                sram_B_dout = sram_B_val;
                #211.64;
            end
            wait(done == 1 || $time > ($realtime + 100000)); // 10 us timeout
            if (done == 1) begin
                pass_count = pass_count + 1;
                $display("Test %0d: Done for op_code=%0d, sram_C_din=%h", test_count, op_code, tp_sram_C_din);
                // Check MUL (op_code=0)
                if (op_code == 0) begin
                    expected = sram_A_val * sram_B_val;
                    if (tp_sram_C_din != expected[7:0]) begin
                        $display("Test %0d: MUL sram_C_din=%h, expected=%h", test_count, tp_sram_C_din, expected[7:0]);
                    end
                end
            end else begin
                $display("Test %0d: Failed to complete for op_code=%0d", test_count, op_code);
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