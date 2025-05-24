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
    logic [7:0] data_out_sync1_reg, data_out_sync2_reg;
    logic valid_sclk, valid_sync1, valid_sync2, valid_ack_sclk, valid_ack_sync1, valid_ack_sync2;
    logic [23:0] data_to_sync;
    logic [4:0] sync_bit_cnt;

    // SPI input processing
    always_ff @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt <= 0;
            valid_sclk <= 0;
            shift_reg <= 0;
        end else begin
            shift_reg <= {shift_reg[22:0], mosi};
            bit_cnt <= bit_cnt + 1;
            if (bit_cnt == 23 && !valid_sclk && !valid_ack_sclk) begin
                data_to_sync <= shift_reg;
                valid_sclk <= 1;
            end else if (valid_ack_sclk) valid_sclk <= 0;
        end
    end

    // Synchronize data_out
    always_ff @(posedge sclk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_sync1_reg <= 0;
            data_out_sync2_reg <= 0;
        end else begin
            data_out_sync1_reg <= data_out;
            data_out_sync2_reg <= data_out_sync1_reg;
        end
    end

    // MISO output
    assign miso = (bit_cnt >= 8) ? data_out_sync2_reg[7 - (bit_cnt - 8)] : 0;

    // Synchronize data to clk domain
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_sync1 <= 0;
            valid_sync2 <= 0;
            valid_ack_sync1 <= 0;
            valid_ack_sync2 <= 0;
            cmd <= 0; tile_i <= 0; tile_j <= 0; op_code <= 0; data_in <= 0;
            valid <= 0;
            sync_bit_cnt <= 0;
        end else begin
            valid_sync1 <= valid_sclk;
            valid_sync2 <= valid_sync1;
            valid <= valid_sync2 && !valid_ack_sync2;
            valid_ack_sync1 <= valid_sync2;
            valid_ack_sync2 <= valid_ack_sync1;
            if (valid_sync2 && !valid_ack_sync2) begin
                sync_bit_cnt <= sync_bit_cnt + 1;
                case (sync_bit_cnt)
                    0: cmd <= data_to_sync[23:16];
                    1: tile_i <= data_to_sync[15:13];
                    2: tile_j <= data_to_sync[12:10];
                    3: op_code <= data_to_sync[9:7];
                    4: data_in <= data_to_sync[7:0];
                endcase
            end
        end
    end

    // Synchronize valid_ack
    always_ff @(posedge sclk or negedge rst_n) begin
        if (!rst_n) valid_ack_sclk <= 0;
        else valid_ack_sclk <= valid_ack_sync2;
    end
endmodule