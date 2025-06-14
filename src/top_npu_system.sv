module top_npu_system (
    input logic clk, rst_n, sclk, mosi, cs_n,
    output logic miso, done
);
    logic [7:0] cmd; // Fixed [7:8] to [7:0]
    logic [2:0] tile_i, tile_j;
    logic [2:0] op_code;
    logic [7:0] data_in, data_out; // Fixed [7:8] to [7:0]
    logic valid;
    logic [7:0] sram_A_dout, sram_B_dout, sram_C_dout; // Fixed [7:8] to [7:0]
    logic [9:0] sram_A_addr, sram_B_addr, sram_C_addr;
    logic sram_A_we, sram_B_we, sram_C_we;
    logic sram_A_ce, sram_B_ce, sram_C_ce;
    logic [7:0] sram_A_din, sram_B_din, sram_C_din; // Fixed [7:8] to [7:0]

    logic tp_sram_A_we, tp_sram_B_we, tp_sram_C_we;
    logic tp_sram_A_ce, tp_sram_B_ce, tp_sram_C_ce;
    logic [9:0] tp_sram_A_addr, tp_sram_B_addr, tp_sram_C_addr;
    logic [7:0] tp_sram_A_din, tp_sram_B_din, tp_sram_C_din; // Fixed [7:8] to [7:0]

    spi_slave spi_inst (
        .clk(clk), .rst_n(rst_n), .sclk(sclk), .mosi(mosi), .cs_n(cs_n),
        .miso(miso), .cmd(cmd), .tile_i(tile_i), .tile_j(tile_j),
        .op_code(op_code), .data_in(data_in), .data_out(data_out), .valid(valid)
    );

    sram_A sram_A_inst (
        .clk(clk), .ce(sram_A_ce), .we(sram_A_we),
        .addr(sram_A_addr), .din(sram_A_din), .dout(sram_A_dout)
    );

    sram_B sram_B_inst (
        .clk(clk), .ce(sram_B_ce), .we(sram_B_we),
        .addr(sram_B_addr), .din(sram_B_din), .dout(sram_B_dout)
    );

    sram_C sram_C_inst (
        .clk(clk), .ce(sram_C_ce), .we(sram_C_we),
        .addr(sram_C_addr), .din(sram_C_din), .dout(sram_C_dout)
    );

    tile_processor tp_inst (
        .clk(clk), .rst_n(rst_n),
        .tile_i(tile_i), .tile_j(tile_j), .op_code(op_code),
        .start(cmd == 8'h02), .sram_A_dout(sram_A_dout), .sram_B_dout(sram_B_dout),
        .tp_sram_A_we(tp_sram_A_we), .tp_sram_B_we(tp_sram_B_we), .tp_sram_C_we(tp_sram_C_we),

        .tp_sram_A_addr(tp_sram_A_addr), .tp_sram_B_addr(tp_sram_B_addr), .tp_sram_C_addr(tp_sram_C_addr),
        .tp_sram_A_din(tp_sram_A_din), .tp_sram_B_din(tp_sram_B_din), .tp_sram_C_din(tp_sram_C_din),
        .done(done)
    );

    logic spi_sram_A_we, spi_sram_B_we, spi_sram_C_we;
    logic [9:0] spi_sram_A_addr, spi_sram_B_addr, spi_sram_C_addr;
    logic [7:0] spi_sram_A_din, spi_sram_B_din, spi_sram_C_din;
    logic spi_sram_A_ce, spi_sram_B_ce, spi_sram_C_ce;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            spi_sram_A_we <= 0; spi_sram_B_we <= 0; spi_sram_C_we <= 0;
            spi_sram_A_ce <= 0; spi_sram_B_ce <= 0; spi_sram_C_ce <= 0;
            spi_sram_A_addr <= 0; spi_sram_B_addr <= 0; spi_sram_C_addr <= 0;
            spi_sram_A_din <= 0; spi_sram_B_din <= 0; spi_sram_C_din <= 0;
        end else if (valid && cmd == 8'h01) begin
            spi_sram_A_we <= ~tile_i[2] & ~tile_j[2];
            spi_sram_B_we <= tile_i[2] & ~tile_j[2];
            spi_sram_C_we <= tile_j[2];
            spi_sram_A_ce <= ~tile_i[2] & ~tile_j[2];
            spi_sram_B_ce <= tile_i[2] & ~tile_j[2];
            spi_sram_C_ce <= tile_j[2];
            spi_sram_A_addr <= {tile_i[1:0], tile_j[1:0], data_in[5:0]};
            spi_sram_B_addr <= {tile_i[1:0], tile_j[1:0], data_in[5:0]};
            spi_sram_C_addr <= {tile_i[1:0], tile_j[1:0], data_in[5:0]};
            spi_sram_A_din <= data_in;
            spi_sram_B_din <= data_in;
            spi_sram_C_din <= data_in;
        end else begin
            spi_sram_A_we <= 0; spi_sram_B_we <= 0; spi_sram_C_we <= 0;
            spi_sram_A_ce <= 0; spi_sram_B_ce <= 0; spi_sram_C_ce <= 0;
        end
    end

    always_comb begin
        sram_A_we = spi_sram_A_we ? spi_sram_A_we : tp_sram_A_we;
        sram_B_we = spi_sram_B_we ? spi_sram_B_we : tp_sram_B_we;
        sram_C_we = spi_sram_C_we ? spi_sram_C_we : tp_sram_C_we;
        sram_A_ce = spi_sram_A_ce | tp_sram_A_ce;
        sram_B_ce = spi_sram_B_ce | tp_sram_B_ce;
        sram_C_ce = spi_sram_C_ce | tp_sram_C_ce;
        sram_A_addr = spi_sram_A_we ? spi_sram_A_addr : tp_sram_A_addr;
        sram_B_addr = spi_sram_B_we ? spi_sram_B_addr : tp_sram_B_addr;
        sram_C_addr = spi_sram_C_we ? spi_sram_C_addr : tp_sram_C_addr;
        sram_A_din = spi_sram_A_we ? spi_sram_A_din : tp_sram_A_din;
        sram_B_din = spi_sram_B_we ? spi_sram_B_din : tp_sram_B_din;
        sram_C_din = spi_sram_C_we ? spi_sram_C_din : tp_sram_C_din;
    end

    // Connect tile processor outputs to SRAM C
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            sram_C_we <= 0;
            sram_C_addr <= 0;
            sram_C_din <= 0;
        end else begin
            sram_C_we <= tp_sram_C_we;
            sram_C_addr <= tp_sram_C_addr;
            sram_C_din <= tp_sram_C_din;
        end
    end

    assign data_out = sram_C_dout;
endmodule