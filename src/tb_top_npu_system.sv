`timescale 1ns/1ns

module tb_top_npu_system;
    timeunit 1ns;
    timeprecision 1ns;

    logic clk, rst_n, sclk, mosi, cs_n, miso, done;
    integer pass_count = 0;
    integer test_count = 0;
    integer error_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    top_npu_system dut (
        .clk, .rst_n, .sclk, .mosi, .cs_n, .miso, .done
    );

    // Clocks: clk (47.25 MHz, 21.164 ns), sclk (10 MHz, 100 ns)
    initial begin
        clk = 0; sclk = 0;
        forever #10.582 clk = ~clk;
        forever #50 sclk = ~sclk;
    end

    // Test procedure
    initial begin
        $display("Starting top_npu_system test");
        rst_n = 0; cs_n = 1; mosi = 0;
        #100; rst_n = 1; #100;

        // Test ADD via SPI
        test_count++;
        $display("Test %0d: ADD", test_count);
        send_spi_cmd(8'h01, 0, 0, 3'd1, 8'h00); // Write data
        send_spi_data(0, 16, 8'h01); // SRAM_A: 4x4 all 1s
        send_spi_data(1, 16, 8'h02); // SRAM_B: 4x4 all 2s
        $display("Debug: Sent SPI cmd=02, tile_i=0, tile_j=0, op_code=1");
        send_spi_cmd(8'h02, 0, 0, 3'd1, 8'h00); // Start ADD
        wait(done || $time > ($realtime + 20000)); // 2 us timeout
        if (done) begin
            check_sram_c(0, 16, 8'h03); // Expect 1+2=3
            if (error_count == 0) begin
                pass_count++;
            end else begin
                $display("Test %0d: ADD failed, %0d errors", test_count, error_count);
                error_count = 0;
            end
        end else begin
            $display("Test %0d: ADD timeout", test_count);
        end

        $display("Test completed: %0d/1 passed, %0d total errors", pass_count, error_count);
        $finish;
    end

    // SPI command task
    task automatic send_spi_cmd(input [7:0] cmd_val, input [2:0] ti, tj, opc, input [7:0] din);
        integer i;
        automatic logic [23:0] spi_data = {cmd_val, ti, tj, opc, din};
        @(negedge sclk); cs_n = 0;
        for (i = 23; i >= 0; i--) begin
            mosi = spi_data[i]; @(negedge sclk);
        end
        @(negedge sclk); cs_n = 1;
        $display("Debug: SPI cmd=%h, tile_i=%0d, tile_j=%0d, op_code=%0d, data_in=%h",
                 cmd_val, ti, tj, opc, din);
    endtask

    // SPI data task
    task automatic send_spi_data(input [1:0] sram_id, input [9:0] size, input [7:0] value);
        integer i;
        for (i = 0; i < size; i++) begin
            send_spi_cmd(8'h01, sram_id[1], sram_id[0], 0, value);
        end
    endtask

    // Check SRAM_C task
    task automatic check_sram_c(input [9:0] start_addr, input [9:0] size, input [7:0] expected);
        integer i, j;
        logic [7:0] miso_data;
        for (i = 0; i < size; i++) begin
            send_spi_cmd(8'h01, 1, 1, 0, start_addr[7:0] + i); // Write addr to SRAM_C
            @(negedge sclk); cs_n = 0;
            for (j = 7; j >= 0; j--) begin
                @(negedge sclk); miso_data[j] = miso;
            end
            cs_n = 1;
            if (miso_data !== expected) begin
                $display("Test %0d: SRAM_C addr=%0d, miso=%h, expected=%h",
                         test_count, start_addr + i, miso_data, expected);
                error_count++;
            end
        end
    endtask

    // Timeout
    initial begin
        #200000; // 200 us
        $display("Simulation timeout");
        $finish;
    end
endmodule