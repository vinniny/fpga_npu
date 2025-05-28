(* MAX_DSP = 5, use_dsp = "hard" *)
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
    logic [31:0] dot_result; // Match matrix_dot output
    logic [15:0] final_result [0:3][0:3];
    logic mul_done, add_done, sub_done, conv_done, dot_done, op_done;
    logic [4:0] i, j, k;

    logic [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    logic [36:0] dsp_out [0:4];
    logic dsp_ce;
    logic [17:0] mul_dsp_a0 [0:4], mul_dsp_b0 [0:4], conv_dsp_a0 [0:4], conv_dsp_b0 [0:4];
    logic mul_dsp_ce, conv_dsp_ce;

    // Pack dot_a, dot_b into 128-bit vectors
    logic [127:0] dot_a_packed, dot_b_packed;
    genvar ga;
    generate
        for (ga = 0; ga < 16; ga = ga + 1) begin : pack_dot_a
            assign dot_a_packed[ga*8 +: 8] = dot_a[ga];
        end
    endgenerate
    genvar gb;
    generate
        for (gb = 0; gb < 16; gb = gb + 1) begin : pack_dot_b
            assign dot_b_packed[gb*8 +: 8] = dot_b[gb];
        end
    endgenerate

    genvar z;
    generate
        for (z = 0; z < 5; z++) begin : gen_dsp
            Gowin_MULTADDALU dsp_inst (
                .a0(dsp_a0[z]), .b0(dsp_b0[z]), .a1(18'd0), .b1(18'd0),
                .dout(dsp_out[z]), .caso(), .ce(dsp_ce), .clk(clk), .reset(!rst_n)
            );
        end
    endgenerate

    matrix_multiplier mul_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == MUL && state == 2),
        .a(a_tile), .b(b_tile), .c(mul_result),
        .dsp_a0(mul_dsp_a0), .dsp_b0(mul_dsp_b0), .dsp_out(dsp_out), .dsp_ce(mul_dsp_ce),
        .done(mul_done)
    );
    matrix_addition add_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == ADD && state == 2),
        .a(add_a), .b(add_b), .c(add_result), .done(add_done)
    );
    matrix_subtraction sub_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == SUB && state == 2),
        .a(add_a), .b(add_b), .c(sub_result), .done(sub_done)
    );
    matrix_convolution conv_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == CONV && state == 2),
        .input_tile(conv_input), .kernel(conv_kernel), .c(conv_result),
        .dsp_a0(conv_dsp_a0), .dsp_b0(conv_dsp_b0), .dsp_out(dsp_out), .dsp_ce(conv_dsp_ce),
        .done(conv_done)
    );
    matrix_dot dot_inst (
        .clk(clk), .rst_n(rst_n), .start(op_code == DOT && state == 2),
        .a(dot_a_packed), .b(dot_b_packed), .c(dot_result), .done(dot_done)
    );

    assign op_done = mul_done || add_done || sub_done || conv_done || dot_done;

    always_comb begin
        case (op_code)
            MUL: begin
                dsp_a0 = mul_dsp_a0;
                dsp_b0 = mul_dsp_b0;
                dsp_ce = mul_dsp_ce;
                final_result = mul_result;
            end
            CONV: begin
                dsp_a0 = conv_dsp_a0;
                dsp_b0 = conv_dsp_b0;
                dsp_ce = conv_dsp_ce;
                final_result = conv_result;
            end
            ADD: begin
                dsp_a0 = '{default: 0};
                dsp_b0 = '{default: 0};
                dsp_ce = 0;
                final_result = add_result;
            end
            SUB: begin
                dsp_a0 = '{default: 0};
                dsp_b0 = '{default: 0};
                dsp_ce = 0;
                final_result = sub_result;
            end
            DOT: begin
                dsp_a0 = '{default: 0};
                dsp_b0 = '{default: 0};
                dsp_ce = 0;
                final_result[0][0] = dot_result[7:0];
                final_result[0][1] = dot_result[15:8];
                final_result[0][2] = dot_result[23:16];
                final_result[0][3] = dot_result[31:24];
                final_result[1][0] = 0; final_result[1][1] = 0; final_result[1][2] = 0; final_result[1][3] = 0;
                final_result[2][0] = 0; final_result[2][1] = 0; final_result[2][2] = 0; final_result[2][3] = 0;
                final_result[3][0] = 0; final_result[3][1] = 0; final_result[3][2] = 0; final_result[3][3] = 0;
            end
            default: begin
                dsp_a0 = '{default: 0};
                dsp_b0 = '{default: 0};
                dsp_ce = 0;
                final_result = '{default: 0};
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tp_sram_A_we <= 0;
            tp_sram_B_we <= 0;
            tp_sram_C_we <= 0;
            tp_sram_A_addr <= 0;
            tp_sram_B_addr <= 0;
            tp_sram_C_addr <= 0;
            tp_sram_A_din <= 0;
            tp_sram_B_din <= 0;
            tp_sram_C_din <= 0;
            done <= 0;
            i <= 0;
            j <= 0;
            k <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 16; y++)
                    a_tile[x][y] <= 0;
            for (int x = 0; x < 16; x++)
                for (int y = 0; y < 4; y++)
                    b_tile[x][y] <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++) begin
                    add_a[x][y] <= 0;
                    add_b[x][y] <= 0;
                end
            for (int x = 0; x < 6; x++)
                for (int y = 0; y < 6; y++)
                    conv_input[x][y] <= 0;
            for (int x = 0; x < 3; x++)
                for (int y = 0; y < 3; y++)
                    conv_kernel[x][y] <= 0;
            for (int x = 0; x < 16; x++) begin
                dot_a[x] <= 0;
                dot_b[x] <= 0;
            end
        end else begin
            case (state)
                IDLE: begin
                    tp_sram_A_we <= 0;
                    tp_sram_B_we <= 0;
                    tp_sram_C_we <= 0;
                    done <= 0;
                    i <= 0;
                    j <= 0;
                    k <= 0;
                    if (start) begin
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    case (op_code)
                        MUL: begin
                            if (i < 4) begin
                                if (j < 16) begin
                                    tp_sram_A_addr <= tile_i * 64 + i * 16 + j;
                                    tp_sram_B_addr <= tile_j * 64 + j * 4 + i;
                                    if (k > 0) begin
                                        a_tile[i][j] <= sram_A_dout;
                                        b_tile[j][i] <= sram_B_dout;
                                    end
                                    j <= j + 1;
                                    k <= k + 1;
                                end else begin
                                    i <= i + 1;
                                    j <= 0;
                                    k <= 0;
                                end
                            end else begin
                                state <= COMPUTE;
                                i <= 0;
                                j <= 0;
                                k <= 0;
                            end
                        end
                        ADD, SUB: begin
                            if (i < 4) begin
                                if (j < 4) begin
                                    tp_sram_A_addr <= tile_i * 16 + i * 4 + j;
                                    tp_sram_B_addr <= tile_j * 16 + i * 4 + j;
                                    if (k > 0) begin
                                        add_a[i][j] <= sram_A_dout;
                                        add_b[i][j] <= sram_B_dout;
                                    end
                                    j <= j + 1;
                                    k <= k + 1;
                                end else begin
                                    i <= i + 1;
                                    j <= 0;
                                    k <= 0;
                                end
                            end else begin
                                state <= COMPUTE;
                                i <= 0;
                                j <= 0;
                                k <= 0;
                            end
                        end
                        CONV: begin
                            if (i < 6) begin
                                if (j < 6) begin
                                    tp_sram_A_addr <= tile_i * 36 + i * 6 + j;
                                    if (i < 3 && j < 3)
                                        tp_sram_B_addr <= tile_j * 9 + i * 3 + j;
                                    if (k > 0) begin
                                        conv_input[i][j] <= sram_A_dout;
                                        if (i < 3 && j < 3)
                                            conv_kernel[i][j] <= sram_B_dout;
                                    end
                                    j <= j + 1;
                                    k <= k + 1;
                                end else begin
                                    i <= i + 1;
                                    j <= 0;
                                    k <= 0;
                                end
                            end else begin
                                state <= COMPUTE;
                                i <= 0;
                                j <= 0;
                                k <= 0;
                            end
                        end
                        DOT: begin
                            if (i < 16) begin
                                tp_sram_A_addr <= tile_i * 16 + i;
                                tp_sram_B_addr <= tile_j * 16 + i;
                                if (k > 0) begin
                                    dot_a[i] <= sram_A_dout;
                                    dot_b[i] <= sram_B_dout;
                                end
                                i <= i + 1;
                                k <= k + 1;
                            end else begin
                                state <= COMPUTE;
                                i <= 0;
                                j <= 0;
                                k <= 0;
                            end
                        end
                    endcase
                end
                COMPUTE: begin
                    if (op_done) begin
                        state <= DONE;
                        i <= 0;
                        j <= 0;
                    end
                end
                DONE: begin
                    if (op_code == DOT) begin
                        if (i < 4) begin
                            tp_sram_C_addr <= tile_i * 32 + i;
                            tp_sram_C_we <= 1;
                            tp_sram_C_din <= final_result[0][i];
                            i <= i + 1;
                        end else begin
                            done <= 1;
                            state <= IDLE;
                            i <= 0;
                            tp_sram_C_we <= 0;
                        end
                    end else begin
                        if (i < 4) begin
                            if (j < 4) begin
                                tp_sram_C_addr <= tile_i * 16 + i * 4 + j;
                                tp_sram_C_we <= 1;
                                tp_sram_C_din <= final_result[i][j];
                                j <= j + 1;
                            end else begin
                                i <= i + 1;
                                j <= 0;
                            end
                        end else begin
                            done <= 1;
                            state <= IDLE;
                            i <= 0;
                            j <= 0;
                            tp_sram_C_we <= 0;
                        end
                    end
                end
            endcase
        end
    end
endmodule