module tb_spi_slave;
    logic sclk, mosi, cs_n, clk, rst_n, miso, valid;
    logic [7:0] cmd, data_in, data_out;
    logic [2:0] tile_i, tile_j, op_code;

    spi_slave dut (
        .sclk(sclk), .mosi(mosi), .cs_n(cs_n), .clk(clk), .rst_n(rst_n),
        .miso(miso), .cmd(cmd), .tile_i(tile_i), .tile_j(tile_j),
        .op_code(op_code), .data_in(data_in), .data_out(data_out), .valid(valid)
    );

    initial begin
        clk = 0; sclk = 0;
        forever begin
            #10.58 clk = ~clk; // 47.25 MHz
            #10 sclk = ~sclk;  // 50 MHz
        end
    end

    initial begin
        rst_n = 0; cs_n = 1; mosi = 0; data_out = 8'h55;
        #100 rst_n = 1;
        #100 cs_n = 0;
        // Send SPI packet: cmd = 8'h01, tile_i = 3'd1, tile_j = 3'd2, op_code = 3'd3, data_in = 8'hAA
        for (int i = 23; i >= 0; i--) begin
            mosi = (i == 23 || i == 15 || i == 11 || i == 8 || i == 7 || i == 6 || i == 5 || i == 4 || i == 3 || i == 2 || i == 1 || i == 0) ? 1 : 0;
            #20;
        end
        cs_n = 1;
        #100;
        if (valid && cmd == 8'h01 && tile_i == 3'd1 && tile_j == 3'd2 && op_code == 3'd3 && data_in == 8'hAA)
            $display("SPI Slave: Correct data received");
        else
            $display("SPI Slave: Data error: cmd=%h, tile_i=%d, tile_j=%d, op_code=%d, data_in=%h", cmd, tile_i, tile_j, op_code, data_in);
        #100 $finish;
    end
endmodule