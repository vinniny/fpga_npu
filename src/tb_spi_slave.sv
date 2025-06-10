`timescale 1ns/1ns

module tb_spi_slave;
    timeunit 1ns;
    timeprecision 1ns;

    reg sclk, mosi, cs_n, clk, rst_n;
    wire miso;
    wire [7:0] cmd, data_in;
    wire [2:0] tile_i, tile_j, op_code;
    reg [7:0] data_out;
    wire valid;
    integer pass_count = 0;
    integer test_count = 0;

    // Instantiate GSR
    GSR GSR(.GSRI(1'b1));

    spi_slave dut (
        .sclk(sclk), .mosi(mosi), .cs_n(cs_n), .clk(clk), .rst_n(rst_n),
        .miso(miso), .cmd(cmd), .tile_i(tile_i), .tile_j(tile_j),
        .op_code(op_code), .data_in(data_in), .data_out(data_out), .valid(valid)
    );

    // Clocks: sclk (50 MHz, 20 ns), clk (47.25 MHz, 21.164 ns)
    initial begin
        sclk = 0;
        forever #100 sclk = ~sclk;
    end
    initial begin
        clk = 0;
        forever #105.82 clk = ~clk;
    end

    // Test procedure
    initial begin
        integer i;
        reg [23:0] spi_data;
        reg [7:0] exp_cmd, exp_data_in;
        reg [2:0] exp_tile_i, exp_tile_j, exp_op_code;
        reg [7:0] received_data;
        $display("Starting spi_slave test with 1000 test cases");
        rst_n = 0; cs_n = 1; mosi = 0; data_out = 0;
        #1000; // 100 ns reset
        rst_n = 1;

        repeat(1000) begin
            @(negedge sclk);
            // Set data_out before transaction
            data_out = $urandom_range(0, 255);
            cs_n = 0;
            // Random 24-bit SPI data
            spi_data = {$urandom_range(0, 2**24-1)};
            exp_cmd = spi_data[23:16];
            exp_tile_i = spi_data[15:13];
            exp_tile_j = spi_data[12:10];
            exp_op_code = spi_data[9:7];
            exp_data_in = spi_data[7:0];
            // Send SPI data
            for (i = 23; i >= 0; i = i - 1) begin
                mosi = spi_data[i];
                @(negedge sclk);
            end

            repeat(16) @(negedge sclk);  // Allow MISO transmission

            // Wait for valid
            wait(valid == 1 || $time > $realtime + 120000); // 12 us timeout
            if (valid == 1) begin
                // Verify outputs
                if (cmd == exp_cmd && tile_i == exp_tile_i && tile_j == exp_tile_j &&
                    op_code == exp_op_code && data_in == exp_data_in) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("Test %0d: cmd=%h, tile_i=%h, tile_j=%h, op_code=%h, data_in=%h; expected %h, %h, %h, %h, %h",
                             test_count, cmd, tile_i, tile_j, op_code, data_in,
                             exp_cmd, exp_tile_i, exp_tile_j, exp_op_code, exp_data_in);
                end
                // Wait for MISO transmission
                repeat(35) @(negedge sclk); // Wait 35 cycles
                received_data = 8'h00;
                for (i = 7; i >= 0; i = i - 1) begin
                    @(posedge sclk);
                    received_data[i] = miso;
                end
                if (received_data == data_out) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("Test %0d: miso received=%h, expected=%h; data_out_sync2=%h",
                             test_count, received_data, data_out, dut.data_out_sync2);
                end
            end else begin
                $display("Test %0d: Failed to receive valid", test_count);
            end
            cs_n = 1;
            #6000; // 600 ns cs_n high
            test_count = test_count + 1;
            #10000; // 1 us between tests
        end
        $display("Test completed: %0d/2000 checks passed", pass_count);
        $finish;
    end

    // Timeout
    initial begin
        #120000000; // 12 ms
        $display("Simulation timeout");
        $finish;
    end
endmodule