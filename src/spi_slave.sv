module spi_slave (
    input sclk, mosi, cs_n, clk, rst_n,
    output miso,
    output logic [7:0] cmd,
    output logic [2:0] tile_i, tile_j, // 8x8 tiles
    output logic [2:0] op_code,
    output logic [7:0] data_in,
    input [7:0] data_out,
    output logic valid
);
    logic [23:0] shift_reg;
    logic [4:0] bit_cnt;

    always_ff @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt <= 0; valid <= 0;
        end else begin
            shift_reg <= {shift_reg[22:0], mosi};
            bit_cnt <= (bit_cnt + 1) & 5'h1F; // Mask to 5 bits (0-31)
            if (bit_cnt == 23) begin
                cmd <= shift_reg[23:16];
                tile_i <= shift_reg[15:13];
                tile_j <= shift_reg[12:10];
                op_code <= shift_reg[9:7];
                data_in <= shift_reg[7:0];
                valid <= 1;
            end
        end
    end
    assign miso = (bit_cnt >= 8) ? data_out[7 - (bit_cnt - 8)] : 0;
endmodule