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
    typedef enum logic [1:0] {IDLE, RECEIVE, TRANSFER} state_t;
    state_t state, next_state;

    logic [23:0] shift_reg;
    logic [4:0] bit_cnt;
    logic [7:0] data_out_reg, data_out_sync1, data_out_sync2;
    logic valid_sclk, valid_sync1, valid_sync2, valid_ack_sclk, valid_ack_sync1, valid_ack_sync2;
    logic [23:0] data_to_sync;
    logic [2:0] sync_bit_cnt;
    logic [1:0] transfer_timeout; // 2-bit for 20 ns timeout

    // Data_out synchronization: clk to sclk
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out_reg <= 0;
        else
            data_out_reg <= data_out;
    end

    always_ff @(posedge sclk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_sync1 <= 0;
            data_out_sync2 <= 0;
        end else begin
            data_out_sync1 <= data_out_reg;
            data_out_sync2 <= data_out_sync1;
        end
    end

    // State machine: sclk domain
    always_ff @(posedge sclk or posedge cs_n) begin
        if (cs_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (!cs_n) next_state = RECEIVE;
            RECEIVE: if (bit_cnt == 23) next_state = TRANSFER;
            TRANSFER: if (valid_ack_sclk || transfer_timeout == 1 || cs_n) next_state = IDLE; // 20 ns timeout
        endcase
    end

    // SPI input processing
    always_ff @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt <= 0;
            shift_reg <= 0;
            valid_sclk <= 0;
            transfer_timeout <= 0;
        end else begin
            case (state)
                IDLE: begin
                    bit_cnt <= 0;
                    transfer_timeout <= 0;
                end
                RECEIVE: begin
                    shift_reg <= {shift_reg[22:0], mosi};
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 23) begin
                        data_to_sync <= {shift_reg[22:0], mosi};
                        valid_sclk <= 1;
                    end
                end
                TRANSFER: begin
                    transfer_timeout <= transfer_timeout + 1;
                    if (valid_ack_sclk || transfer_timeout == 1) begin
                        valid_sclk <= 0;
                        bit_cnt <= 0; // Reset for MISO
                    end
                end
            endcase
        end
    end

    // MISO output
    always_ff @(posedge sclk or posedge cs_n) begin
        if (cs_n)
            miso <= 0;
        else if (bit_cnt >= 0 && bit_cnt < 8) // MISO at bit_cnt=0 to 7
            miso <= data_out_sync2[7 - bit_cnt];
    end

    // Synchronization: sclk to clk
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
                    4: begin
                        data_in <= data_to_sync[7:0];
                        sync_bit_cnt <= 0;
                    end
                endcase
            end
        end
    end

    // Acknowledge: clk to sclk
    always_ff @(posedge sclk or negedge rst_n) begin
        if (!rst_n)
            valid_ack_sclk <= 0;
        else
            valid_ack_sclk <= valid_ack_sync2;
    end
endmodule