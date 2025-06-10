`timescale 1ns/1ns

module tb_tile_processor;
    timeunit 1ns;
    timeprecision 1ns;

    logic clk, rst_n, start, done;
    logic [2:0] tile_i, tile_j, op_code;
    logic [7:0] sram_A_dout, sram_B_dout, sram_C_dout;
    logic [9:0] tp_sram_A_addr, tp_sram_B_addr, tp_sram_C_addr;
    logic [7:0] tp_sram_A_din, tp_sram_B_din, tp_sram_C_din;
    logic tp_sram_A_we, tp_sram_B_we, tp_sram_C_we;
    logic tp_sram_A_ce, tp_sram_B_ce, tp_sram_C_ce;
    integer pass_count = 0;
    integer test_count = 0;
    integer error_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    // Local signals for SRAM_C control
    logic sram_c_ce, sram_c_we;
    logic [9:0] sram_c_addr;

    // Instantiate DUT and SRAMs
    tile_processor dut (
        .clk, .rst_n, .start, .tile_i, .tile_j, .op_code,
        .sram_A_dout, .sram_B_dout,
        .tp_sram_A_we, .tp_sram_B_we, .tp_sram_C_we,
        .tp_sram_A_ce, .tp_sram_B_ce, .tp_sram_C_ce,
        .tp_sram_A_addr, .tp_sram_B_addr, .tp_sram_C_addr,
        .tp_sram_A_din, .tp_sram_B_din, .tp_sram_C_din,
        .done
    );

    sram_A sram_a (
        .clk, .ce(tp_sram_A_ce), .we(tp_sram_A_we),
        .addr(tp_sram_A_addr), .din(tp_sram_A_din), .dout(sram_A_dout)
    );
    sram_B sram_b (
        .clk, .ce(tp_sram_B_ce), .we(tp_sram_B_we),
        .addr(tp_sram_B_addr), .din(tp_sram_B_din), .dout(sram_B_dout)
    );
    sram_C sram_c (
        .clk, .ce(sram_c_ce), .we(sram_c_we),
        .addr(sram_c_addr), .din(tp_sram_C_din), .dout(sram_C_dout)
    );

    // Clock: 47.25 MHz (21.164 ns)
    initial begin
        clk = 0;
        forever #10.582 clk = ~clk;
    end

    // Test procedure
    initial begin
        $display("Starting tile_processor test");
        rst_n = 0; start = 0; tile_i = 0; tile_j = 0; op_code = 0;
        sram_c_ce = 0; sram_c_we = 0; sram_c_addr = 0;
        #100; rst_n = 1; #100;

        // Test ADD (op_code=1)
        test_count++;
        $display("Test %0d: ADD", test_count);
        op_code = 3'd1; tile_i = 0; tile_j = 0;
        init_sram(0, 16, 8'h01); // SRAM_A: 4x4 all 1s
        init_sram(1, 16, 8'h02); // SRAM_B: 4x4 all 2s
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        wait(done || $time > ($realtime + 10000)); // 1 us timeout
        if (done) begin
            $display("Debug: op_done=%b, add_done=%b, final_result[0][0]=%h, add_result[0][0]=%h, write_count=%0d, state=%0s",
                     dut.op_done, dut.add_done, dut.final_result[0][0], dut.add_result[0][0], dut.write_count, dut.state);
            check_sram_c(0, 16, 8'h03); // Expect 1+2=3
            if (error_count == 0) begin
                pass_count++;
            end else begin
                $display("Test %0d: ADD failed, %0d errors", test_count, error_count);
                error_count = 0; // Reset for next test
            end
        end else begin
            $display("Test %0d: ADD timeout", test_count);
        end

        // Test SUB (op_code=2)
        test_count++;
        $display("Test %0d: SUB", test_count);
        op_code = 3'd2; tile_i = 0; tile_j = 0;
        init_sram(0, 16, 8'h05); // SRAM_A: 4x4 all 5s
        init_sram(1, 16, 8'h03); // SRAM_B: 4x4 all 3s
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        wait(done || $time > ($realtime + 10000));
        if (done) begin
            $display("Debug: op_done=%b, sub_done=%b, final_result[0][0]=%h, sub_result[0][0]=%h, write_count=%0d, state=%0s",
                     dut.op_done, dut.sub_done, dut.final_result[0][0], dut.sub_result[0][0], dut.write_count, dut.state);
            check_sram_c(0, 16, 8'h02); // Expect 5-3=2
            if (error_count == 0) begin
                pass_count++;
            end else begin
                $display("Test %0d: SUB failed, %0d errors", test_count, error_count);
                error_count = 0;
            end
        end else begin
            $display("Test %0d: SUB timeout", test_count);
        end

        // Test CONV (op_code=3)
        test_count++;
        $display("Test %0d: CONV", test_count);
        op_code = 3'd3; tile_i = 0; tile_j = 0;
        init_sram(0, 36, 8'h01); // SRAM_A: 6x6 all 1s
        init_sram(1, 9, 8'h01); // SRAM_B: 3x3 all 1s
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        wait(done || $time > ($realtime + 10000));
        if (done) begin
            $display("Debug: op_done=%b, conv_done=%b, final_result[0][0]=%h, conv_result[0][0]=%h, write_count=%0d, state=%0s",
                     dut.op_done, dut.conv_done, dut.final_result[0][0], dut.conv_result[0][0], dut.write_count, dut.state);
            check_sram_c(0, 16, 8'h09); // Expect 1*9=9
            if (error_count == 0) begin
                pass_count++;
            end else begin
                $display("Test %0d: CONV failed, %0d errors", test_count, error_count);
                error_count = 0;
            end
        end else begin
            $display("Test %0d: CONV timeout", test_count);
        end

        // Test DOT (op_code=4)
        test_count++;
        $display("Test %0d: DOT", test_count);
        op_code = 3'd4; tile_i = 0; tile_j = 0;
        init_sram(0, 16, 8'h01); // SRAM_A: 16x1 all 1s
        init_sram(1, 16, 8'h01); // SRAM_B: 16x1 all 1s
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        wait(done || $time > ($realtime + 10000));
        if (done) begin
            $display("Debug: op_done=%b, dot_done=%b, final_result[0][0]=%h, dot_result=%h, write_count=%0d, state=%0s",
                     dut.op_done, dut.dot_done, dut.final_result[0][0], dut.dot_result, dut.write_count, dut.state);
            check_sram_c(0, 4, 8'h10); // Expect sum=16
            if (error_count == 0) begin
                pass_count++;
            end else begin
                $display("Test %0d: DOT failed, %0d errors", test_count, error_count);
                error_count = 0;
            end
        end else begin
            $display("Test %0d: DOT timeout", test_count);
        end

        $display("Test completed: %0d/4 passed, %0d total errors", pass_count, error_count);
        $finish;
    end

    // Initialize SRAM task
    task automatic init_sram(input [1:0] sram_id, input [9:0] size, input [7:8] value);
        integer i;
        for (i = 0; i < size; i++) begin
            @(negedge clk);
            case (sram_id)
                0: sram_a.mem[i] = value;
                1: sram_b.mem[i] = value;
            endcase
        end
    endtask

    // Check SRAM_C task
    task automatic check_sram_c(input [9:0] start_addr, input [9:0] size, input [7:0] expected);
        integer i;
        for (i = 0; i < size; i++) begin
            @(negedge clk);
            sram_c_ce = 1; sram_c_we = 0; sram_c_addr = start_addr + i;
            @(negedge clk);
            if (sram_C_dout !== expected) begin
                $display("Test %0d: SRAM_C addr=%0d, dout=%h, expected=%h",
                         test_count, start_addr + i, sram_C_dout, expected);
                error_count++;
            end
            $display("Debug: addr=%0d, tp_sram_C_we=%b, tp_sram_C_ce=%b, tp_sram_C_din=%h",
                     sram_c_addr, tp_sram_C_we, tp_sram_C_ce, tp_sram_C_din);
        end
        sram_c_ce = 0;
    endtask

    // Timeout
    initial begin
        #100000; // 100 us
        $display("Simulation timeout");
        $finish;
    end

    // Assertions
    always @(posedge clk) begin
        if (dut.state == 2'h3 && dut.write_count < (op_code == 3'd4 ? 4 : 16)) begin
            assert (tp_sram_C_we == 1) else
                $display("Error: tp_sram_C_we=0 in DONE state, write_count=%0d", dut.write_count);
            assert (tp_sram_C_ce == 1) else
                $display("Error: tp_sram_C_ce=0 in DONE state, write_count=%0d", dut.write_count);
        end
    end
endmodule