module spi_slave (
    input logic sclk, mosi, cs_n, clk, rst_n,
    output logic miso,
    output logic [7:0] cmd,
    output logic [2:0] tile_i, tile_j,
    output logic [2:0] op_code,
    output logic [7:0] data_in,
    input logic [7:0] data_out,
    output logic valid
);
    logic [23:0] shift_reg;
    logic [4:0] bit_cnt;
    logic [7:0] cmd_sclk, data_in_sclk, data_out_sync1, data_out_sync2;
    logic [2:0] tile_i_sclk, tile_j_sclk, op_code_sclk;
    logic valid_sclk, valid_sync1, valid_sync2, valid_ack_sclk, valid_ack_sync1, valid_ack_sync2;

    // SPI input processing (sclk domain)
    always_ff @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt <= 0;
            valid_sclk <= 0;
            shift_reg <= 0;
        end else begin
            shift_reg <= {shift_reg[22:0], mosi};
            bit_cnt <= (bit_cnt + 1) & 5'h1F;
            if (bit_cnt == 23 && !valid_sclk && !valid_ack_sclk) begin
                cmd_sclk <= shift_reg[23:16];
                tile_i_sclk <= shift_reg[15:13];
                tile_j_sclk <= shift_reg[12:10];
                op_code_sclk <= shift_reg[9:7];
                data_in_sclk <= shift_reg[7:0];
                valid_sclk <= 1;
            end else if (valid_ack_sclk) begin
                valid_sclk <= 0;
            end
        end
    end

    // Synchronize data_out to sclk domain for miso
    (* keep = "true" *) logic [7:0] data_out_sync1_reg, data_out_sync2_reg;
    always_ff @(posedge sclk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_sync1_reg <= 0;
            data_out_sync2_reg <= 0;
        end else begin
            data_out_sync1_reg <= data_out;
            data_out_sync2_reg <= data_out_sync1_reg;
        end
    end
    assign data_out_sync1 = data_out_sync1_reg;
    assign data_out_sync2 = data_out_sync2_reg;

    // MISO output (sclk domain)
    assign miso = (bit_cnt >= 8) ? data_out_sync2[7 - (bit_cnt - 8)] : 0;

    // Synchronize valid and data to clk (100 MHz) domain with handshake
    (* keep = "true" *) logic valid_sync1_reg, valid_sync2_reg;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_sync1_reg <= 0;
            valid_sync2_reg <= 0;
            valid_ack_sync1 <= 0;
            valid_ack_sync2 <= 0;
            cmd <= 0; tile_i <= 0; tile_j <= 0; op_code <= 0; data_in <= 0;
            valid <= 0;
        end else begin
            valid_sync1_reg <= valid_sclk;
            valid_sync2_reg <= valid_sync1_reg;
            valid <= valid_sync2_reg && !valid_ack_sync2; // Pulse valid for one cycle
            valid_ack_sync1 <= valid_sync2_reg;
            valid_ack_sync2 <= valid_ack_sync1;
            if (valid_sync2_reg && !valid_ack_sync2) begin
                cmd <= cmd_sclk;
                tile_i <= tile_i_sclk;
                tile_j <= tile_j_sclk;
                op_code <= op_code_sclk;
                data_in <= data_in_sclk;
            end
        end
    end

    // Synchronize valid_ack back to sclk domain
    (* keep = "true" *) logic valid_ack_sclk_reg;
    always_ff @(posedge sclk or negedge rst_n) begin
        if (!rst_n)
            valid_ack_sclk_reg <= 0;
        else
            valid_ack_sclk_reg <= valid_ack_sync2;
    end
    assign valid_ack_sclk = valid_ack_sclk_reg;
endmodule
