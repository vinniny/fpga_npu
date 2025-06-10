module spi_slave (
    input logic sclk, mosi, cs_n, clk, rst_n,
    output logic miso,
    output logic [7:0] cmd,
    output logic [2:0] tile_i, tile_j,
    output logic [2:0] op_code,
    output logic [7:0] data_in,
    input  logic [7:0] data_out,
    output logic valid
);
    typedef enum logic [1:0] {IDLE, RECEIVE, TRANSFER} state_t;
    state_t state, next_state;

    logic [23:0] shift_reg;
    logic [4:0] bit_cnt;
    logic [3:0] miso_bit_cnt;
    logic [7:0] data_out_reg, data_out_sync1, data_out_sync2;
    logic [7:0] miso_shift_reg;
    logic [5:0] transfer_timeout;

    // Synchronize data_out to sclk domain
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out_reg <= 8'h00;
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

    // State transition
    always_ff @(posedge sclk or posedge cs_n) begin
        if (cs_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:    if (!cs_n) next_state = RECEIVE;
            RECEIVE: if (bit_cnt >= 23 && !cs_n) next_state = TRANSFER;
            TRANSFER: if (miso_bit_cnt >= 8 || transfer_timeout >= 32 || cs_n) next_state = IDLE;
        endcase
    end

    // SPI reception and FSM actions
    always_ff @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt <= 0;
            shift_reg <= 0;
            valid <= 0;
            cmd <= 0;
            tile_i <= 0;
            tile_j <= 0;
            op_code <= 0;
            data_in <= 0;
        end else begin
            case (state)
                RECEIVE: begin
                    shift_reg <= {mosi, shift_reg[23:1]}; // Right-shift for MSB-first
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 23) begin // Capture at 24th bit
                        cmd     <= shift_reg[22:15]; // 8-bit cmd
                        tile_i  <= shift_reg[14:12];
                        tile_j  <= shift_reg[11:9];
                        op_code <= shift_reg[8:6];
                        data_in <= {shift_reg[6:0], mosi}; // 8-bit data
                        valid   <= 1'b1;
                        $display("RECEIVED full 24 bits: cmd=%h, tile_i=%0d, tile_j=%0d, op_code=%0d, data_in=%h, time=%0t",
                                 shift_reg[22:15], shift_reg[14:12], shift_reg[11:9], shift_reg[8:6], {shift_reg[6:0], mosi}, $time);
                    end else begin
                        valid <= (bit_cnt == 23) ? 1'b1 : 1'b0;
                    end
                end
                TRANSFER: begin
                    if (miso_bit_cnt == 7)
                        valid <= 1'b0; // Clear valid after full transfer
                end
                default: begin
                    valid <= 1'b0;
                end
            endcase
        end
    end

    // MISO shifting
    always_ff @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            miso_shift_reg <= 8'h00;
            miso_bit_cnt <= 0;
            miso <= 1'b0;
            transfer_timeout <= 0;
        end else begin
            case (state)
                TRANSFER: begin
                    if (miso_bit_cnt == 0) begin
                        miso_shift_reg <= data_out_sync2;
                        $display("TRANSFER INIT: loading miso_shift_reg = %h, time=%0t", data_out_sync2, $time);
                    end
                    
                    miso <= miso_shift_reg[7 - miso_bit_cnt]; // MSB-first
                    $display("TRANSFER STATE: miso <= %b from %h, bit_cnt=%0d, time=%0t",
                             miso_shift_reg[7 - miso_bit_cnt], miso_shift_reg, miso_bit_cnt, $time);
                    
                    miso_bit_cnt <= miso_bit_cnt + 1;
                    if (miso_bit_cnt == 7)
                        miso_bit_cnt <= 0;
                    transfer_timeout <= transfer_timeout + 1;
                end
                RECEIVE: if (bit_cnt == 23) begin
                    miso_bit_cnt <= 0;
                    miso_shift_reg <= 8'h00;
                    miso <= 1'b0;
                    transfer_timeout <= 0;
                end
                default: begin
                    miso <= 1'b0;
                    transfer_timeout <= 0;
                end
            endcase
        end
    end
endmodule