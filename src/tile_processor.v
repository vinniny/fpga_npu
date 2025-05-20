(* MAX_DSP = 5 *)
module tile_processor (
    input logic clk, rst_n, start,
    input logic [2:0] tile_i, tile_j,
    input logic [2:0] op_code,
    input logic [7:0] sram_A_dout, sram_B_dout,
    output logic tp_sram_A_we, tp_sram_B_we, tp_sram_C_we,
    output logic [9:0] tp_sram_A_addr, tp_sram_B_addr, tp_sram_C_addr,
    output logic [7:0] tp_sram_A_din, tp_sram_B_din, tp_sram_C_din,
    output logic done
);
    parameter MUL = 3'd0, ADD = 3'd1, SUB = 3'd2, CONV = 3'd3, DOT = 3'd4;
    typedef enum logic [1:0] {IDLE, LOAD, COMPUTE, DONE} state_t;
    state_t state;
    logic [7:0] a_tile [0:3][0:15], b_tile [0:15][0:3];
    logic [7:0] add_a [0:3][0:3], add_b [0:3][0:3];
    logic [7:0] conv_input [0:5][0:5], conv_kernel [0:2][0:2];
    logic [7:0] dot_a [0:15], dot_b [0:15];
    logic [15:0] mul_result [0:3][0:3], add_result [0:3][0:3], sub_result [0:3][0:3], conv_result [0:3][0:3];
    logic [15:0] dot_result, final_result [0:3][0:3];
    logic mul_done, add_done, sub_done, conv_done, dot_done, op_done;
    logic [4:0] i, j, k; // 0 to 15 max, 5 bits

    // Shared DSP block (5 DSPs)
    logic [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    logic [36:0] dsp_out [0:4];
    logic dsp_ce;

    // Intermediate DSP signals
    logic [17:0] mul_dsp_a0 [0:4], mul_dsp_b0 [0:4], conv_dsp_a0 [0:4], conv_dsp_b0 [0:4];
    logic mul_dsp_ce, conv_dsp_ce;

    genvar z;
    generate
        for (z = 0; z < 5; z++) begin : gen_dsp
            Gowin_MULTADDALU dsp_inst (
                .a0(dsp_a0[z]),
                .b0(dsp_b0[z]),
                .a1(18'd0),
                .b1(18'd0),
                .dout(dsp_out[z]),
                .caso(),
                .ce(dsp_ce),
                .clk(clk),
                .reset(~rst_n)
            );
        end
    endgenerate

    matrix_multiplier mul_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == MUL && state == COMPUTE),
        .a(a_tile), .b(b_tile), .c(mul_result),
        .dsp_a0(mul_dsp_a0), .dsp_b0(mul_dsp_b0), .dsp_out(dsp_out), .dsp_ce(mul_dsp_ce),
        .done(mul_done)
    );
    matrix_addition add_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == ADD && state == COMPUTE),
        .a(add_a), .b(add_b), .c(add_result), .done(add_done)
    );
    matrix_subtraction sub_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == SUB && state == COMPUTE),
        .a(add_a), .b(add_b), .c(sub_result), .done(sub_done)
    );
    matrix_convolution conv_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == CONV && state == COMPUTE),
        .input_tile(conv_input), .kernel(conv_kernel), .c(conv_result),
        .dsp_a0(conv_dsp_a0), .dsp_b0(conv_dsp_b0), .dsp_out(dsp_out), .dsp_ce(conv_dsp_ce),
        .done(conv_done)
    );
    matrix_dot dot_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == DOT && state == COMPUTE),
        .a(dot_a), .b(dot_b), .c(dot_result), .done(dot_done)
    );

    always_comb begin
        case (op_code)
            MUL: begin
                for (int z = 0; z < 5; z++) begin
                    dsp_a0[z] = mul_dsp_a0[z];
                    dsp_b0[z] = mul_dsp_b0[z];
                end
                dsp_ce = mul_dsp_ce;
            end
            CONV: begin
                for (int z = 0; z < 5; z++) begin
                    dsp_a0[z] = conv_dsp_a0[z];
                    dsp_b0[z] = conv_dsp_b0[z];
                end
                dsp_ce = conv_dsp_ce;
            end
            default: begin
                for (int z = 0; z < 5; z++) begin
                    dsp_a0[z] = 0;
                    dsp_b0[z] = 0;
                end
                dsp_ce = 0;
            end
        endcase
    end

    always_comb begin
        op_done = 0;
        for (int x = 0; x < 4; x++)
            for (int y = 0; y < 4; y++)
                final_result[x][y] = 0;
        case (op_code)
            MUL: begin
                op_done = mul_done;
                for (int x = 0; x < 4; x++)
                    for (int y = 0; y < 4; y++)
                        final_result[x][y] = mul_result[x][y];
            end
            ADD: begin
                op_done = add_done;
                for (int x = 0; x < 4; x++)
                    for (int y = 0; y < 4; y++)
                        final_result[x][y] = add_result[x][y];
            end
            SUB: begin
                op_done = sub_done;
                for (int x = 0; x < 4; x++)
                    for (int y = 0; y < 4; y++)
                        final_result[x][y] = sub_result[x][y];
            end
            CONV: begin
                op_done = conv_done;
                for (int x = 0; x < 4; x++)
                    for (int y = 0; y < 4; y++)
                        final_result[x][y] = conv_result[x][y];
            end
            DOT: begin
                op_done = dot_done;
            end
            default: begin
                op_done = 0;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE; i <= 0; j <= 0; k <= 0;
            done <= 0; tp_sram_A_we <= 0; tp_sram_B_we <= 0; tp_sram_C_we <= 0;
            tp_sram_A_din <= 0; tp_sram_B_din <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 16; y++) begin
                    a_tile[x][y] <= 0;
                    b_tile[y][x] <= 0;
                end
            for (int x = 0; x < 16; x++) begin
                dot_a[x] <= 0;
                dot_b[x] <= 0;
            end
        end else begin
            tp_sram_A_din <= 0;
            tp_sram_B_din <= 0;
            case (state)
                IDLE: if (start) begin
                    state <= LOAD; i <= 0; j <= 0; k <= 0;
                end
                LOAD: begin
                    case (op_code)
                        MUL: begin
                            tp_sram_A_addr <= 10'((tile_i * 32) + (i * 16) + k); // Cast to 10 bits
                            tp_sram_B_addr <= 10'((k * 4) + (tile_j * 1) + j); // Cast to 10 bits
                            if (i < 4 && k < 16) begin
                                a_tile[i][k] <= sram_A_dout;
                                b_tile[k][j] <= sram_B_dout;
                                k <= 5'(k + 1); // Explicitly cast to 5 bits
                            end else if (i < 4) begin
                                i <= 5'(i + 1); // Explicitly cast to 5 bits
                                k <= 0;
                            end else begin
                                state <= COMPUTE;
                            end
                        end
                        ADD, SUB: begin
                            tp_sram_A_addr <= 10'((tile_i * 32) + (i * 4) + j); // Cast to 10 bits
                            tp_sram_B_addr <= 10'((tile_i * 32) + (i * 4) + j); // Cast to 10 bits
                            if (i < 4 && j < 4) begin
                                add_a[i][j] <= sram_A_dout;
                                add_b[i][j] <= sram_B_dout;
                                j <= 5'(j + 1); // Explicitly cast to 5 bits
                            end else if (i < 4) begin
                                i <= 5'(i + 1); // Explicitly cast to 5 bits
                                j <= 0;
                            end else begin
                                state <= COMPUTE;
                            end
                        end
                        CONV: begin
                            tp_sram_A_addr <= 10'((tile_i * 32) + (i * 6) + j); // Cast to 10 bits
                            tp_sram_B_addr <= 10'((tile_i * 32) + (i * 3) + j); // Cast to 10 bits
                            if (i < 6 && j < 6) begin
                                conv_input[i][j] <= sram_A_dout;
                                if (i < 3 && j < 3)
                                    conv_kernel[i][j] <= sram_B_dout;
                                j <= 5'(j + 1); // Explicitly cast to 5 bits
                            end else if (i < 6) begin
                                i <= 5'(i + 1); // Explicitly cast to 5 bits
                                j <= 0;
                            end else begin
                                state <= COMPUTE;
                            end
                        end
                        DOT: begin
                            tp_sram_A_addr <= 10'((tile_i * 16) + k); // Cast to 10 bits
                            tp_sram_B_addr <= 10'((tile_j * 16) + k); // Cast to 10 bits
                            if (k < 16) begin
                                dot_a[k] <= sram_A_dout;
                                dot_b[k] <= sram_B_dout;
                                k <= 5'(k + 1); // Explicitly cast to 5 bits
                            end else begin
                                state <= COMPUTE;
                            end
                        end
                    endcase
                end
                COMPUTE: if (op_done) begin
                    state <= DONE; i <= 0; j <= 0;
                end
                DONE: begin
                    tp_sram_C_addr <= 10'((tile_i * 32) + (i * 4) + j); // Cast to 10 bits
                    tp_sram_C_we <= 1;
                    if (op_code == DOT) begin
                        tp_sram_C_din <= dot_result[7:0];
                        done <= 1; state <= IDLE;
                    end else if (i < 4 && j < 4) begin
                        tp_sram_C_din <= final_result[i][j][7:0];
                        j <= 5'(j + 1); // Explicitly cast to 5 bits
                    end else if (i < 4) begin
                        i <= 5'(i + 1); // Explicitly cast to 5 bits
                        j <= 0;
                    end else begin
                        done <= 1; state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule