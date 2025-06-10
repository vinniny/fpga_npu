module tile_processor (
    input logic clk, rst_n, start,
    input logic [2:0] tile_i, tile_j,
    input logic [2:0] op_code,
    input logic [7:0] sram_A_dout, sram_B_dout,
    output logic tp_sram_A_we, tp_sram_B_we, tp_sram_C_we,
    output logic tp_sram_A_ce, tp_sram_B_ce, tp_sram_C_ce,
    output logic [9:0] tp_sram_A_addr, tp_sram_B_addr, tp_sram_C_addr,
    output logic [7:0] tp_sram_A_din, tp_sram_B_din, tp_sram_C_din,
    output logic done
);
    parameter MUL = 3'd0, ADD = 3'd1, SUB = 3'd2, CONV = 3'd3, DOT = 3'd4;
    typedef enum logic [1:0] {IDLE, LOAD, COMPUTE, DONE} state_t;
    state_t state;

    logic [7:0] a_tile [0:3][0:15], b_tile [0:15][0:3];
    logic [7:0] add_a [0:3][0:3], add_b [0:3][0:3];
    logic signed [7:0] conv_input [0:5][0:5], conv_kernel [0:2][0:2];
    logic [7:0] dot_a [0:15], dot_b [0:15];
    logic [15:0] add_result [0:3][0:3], sub_result [0:3][0:3];
    logic signed [15:0] conv_result [0:3][0:3];
    logic [31:0] dot_result;
    logic [15:0] final_result [0:3][0:3];
    logic add_done, sub_done, conv_done, dot_done, op_done;
    logic [4:0] i, j, k;
    logic [4:0] write_count; // Increased to 5 bits to handle 16 writes

    logic signed [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    logic signed [36:0] dsp_out [0:4];
    logic dsp_ce;
    logic signed [17:0] conv_dsp_a0 [0:4], conv_dsp_b0 [0:4];
    logic conv_dsp_ce;
    logic mul_done;

    // Pack dot_a, dot_b into 128-bit vectors
    logic [127:0] dot_a_packed, dot_b_packed;
    assign dot_a_packed[7:0]   = dot_a[0];  assign dot_a_packed[15:8]  = dot_a[1];
    assign dot_a_packed[23:16] = dot_a[2];  assign dot_a_packed[31:24] = dot_a[3];
    assign dot_a_packed[39:32] = dot_a[4];  assign dot_a_packed[47:40] = dot_a[5];
    assign dot_a_packed[55:48] = dot_a[6];  assign dot_a_packed[63:56] = dot_a[7];
    assign dot_a_packed[71:64] = dot_a[8];  assign dot_a_packed[79:72] = dot_a[9];
    assign dot_a_packed[87:80] = dot_a[10]; assign dot_a_packed[95:88] = dot_a[11];
    assign dot_a_packed[103:96] = dot_a[12]; assign dot_a_packed[111:104] = dot_a[13];
    assign dot_a_packed[119:112] = dot_a[14]; assign dot_a_packed[127:120] = dot_a[15];
    assign dot_b_packed[7:0]   = dot_b[0];  assign dot_b_packed[15:8]  = dot_b[1];
    assign dot_b_packed[23:16] = dot_b[2];  assign dot_b_packed[31:24] = dot_b[3];
    assign dot_b_packed[39:32] = dot_b[4];  assign dot_b_packed[47:40] = dot_b[5];
    assign dot_b_packed[55:48] = dot_b[6];  assign dot_b_packed[63:56] = dot_b[7];
    assign dot_b_packed[71:64] = dot_b[8];  assign dot_b_packed[79:72] = dot_b[9];
    assign dot_b_packed[87:80] = dot_b[10]; assign dot_b_packed[95:88] = dot_b[11];
    assign dot_b_packed[103:96] = dot_b[12]; assign dot_b_packed[111:104] = dot_b[13];
    assign dot_b_packed[119:112] = dot_b[14]; assign dot_b_packed[127:120] = dot_b[15];

    // DSP instances
    Gowin_MULTADDALU dsp_inst_0 (
        .a0(dsp_a0[0]), .b0(dsp_b0[0]), .a1(18'd0), .b1(18'd0),
        .dout(dsp_out[0]), .caso(), .ce(dsp_ce), .clk(clk), .reset(!rst_n)
    );
    Gowin_MULTADDALU dsp_inst_1 (
        .a0(dsp_a0[1]), .b0(dsp_b0[1]), .a1(18'd0), .b1(18'd0),
        .dout(dsp_out[1]), .caso(), .ce(dsp_ce), .clk(clk), .reset(!rst_n)
    );
    Gowin_MULTADDALU dsp_inst_2 (
        .a0(dsp_a0[2]), .b0(dsp_b0[2]), .a1(18'd0), .b1(18'd0),
        .dout(dsp_out[2]), .caso(), .ce(dsp_ce), .clk(clk), .reset(!rst_n)
    );
    Gowin_MULTADDALU dsp_inst_3 (
        .a0(dsp_a0[3]), .b0(dsp_b0[3]), .a1(18'd0), .b1(18'd0),
        .dout(dsp_out[3]), .caso(), .ce(dsp_ce), .clk(clk), .reset(!rst_n)
    );
    Gowin_MULTADDALU dsp_inst_4 (
        .a0(dsp_a0[4]), .b0(dsp_b0[4]), .a1(18'd0), .b1(18'd0),
        .dout(dsp_out[4]), .caso(), .ce(dsp_ce), .clk(clk), .reset(!rst_n)
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

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mul_done <= 0;
        else if (op_code == MUL && state == COMPUTE)
            mul_done <= 1;
        else
            mul_done <= 0;
    end

    assign op_done = mul_done || add_done || sub_done || conv_done || dot_done;

    always_comb begin
        integer x, y;
        for (x = 0; x < 4; x++)
            for (y = 0; y < 4; y++)
                final_result[x][y] = 0; // Initialize to avoid xx
        case (op_code)
            MUL: begin
                for (x = 0; x < 5; x++) begin
                    dsp_a0[x] = 0;
                    dsp_b0[x] = 0;
                end
                dsp_ce = 0;
            end
            CONV: begin
                for (x = 0; x < 5; x++) begin
                    dsp_a0[x] = conv_dsp_a0[x];
                    dsp_b0[x] = conv_dsp_b0[x];
                end
                dsp_ce = conv_dsp_ce;
                for (x = 0; x < 4; x++)
                    for (y = 0; y < 4; y++)
                        final_result[x][y] = $unsigned(conv_result[x][y]);
            end
            ADD: begin
                for (x = 0; x < 5; x++) begin
                    dsp_a0[x] = 0;
                    dsp_b0[x] = 0;
                end
                dsp_ce = 0;
                for (x = 0; x < 4; x++)
                    for (y = 0; y < 4; y++)
                        final_result[x][y] = add_result[x][y];
            end
            SUB: begin
                for (x = 0; x < 5; x++) begin
                    dsp_a0[x] = 0;
                    dsp_b0[x] = 0;
                end
                dsp_ce = 0;
                for (x = 0; x < 4; x++)
                    for (y = 0; y < 4; y++)
                        final_result[x][y] = sub_result[x][y];
            end
            DOT: begin
                for (x = 0; x < 5; x++) begin
                    dsp_a0[x] = 0;
                    dsp_b0[x] = 0;
                end
                dsp_ce = 0;
                final_result[0][0] = dot_result[7:0];
                final_result[0][1] = dot_result[15:8];
                final_result[0][2] = dot_result[23:16];
                final_result[0][3] = dot_result[31:24];
            end
            default: begin
                for (x = 0; x < 5; x++) begin
                    dsp_a0[x] = 0;
                    dsp_b0[x] = 0;
                end
                dsp_ce = 0;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tp_sram_A_we <= 0;
            tp_sram_B_we <= 0;
            tp_sram_C_we <= 0;
            tp_sram_A_ce <= 0;
            tp_sram_B_ce <= 0;
            tp_sram_C_ce <= 0;
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
            write_count <= 0;
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
                    tp_sram_A_ce <= 0;
                    tp_sram_B_ce <= 0;
                    tp_sram_C_ce <= 0;
                    done <= 0;
                    i <= 0;
                    j <= 0;
                    k <= 0;
                    write_count <= 0;
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
                                    tp_sram_A_ce <= 1;
                                    tp_sram_B_ce <= 1;
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
                                tp_sram_A_ce <= 0;
                                tp_sram_B_ce <= 0;
                            end
                        end
                        ADD, SUB: begin
                            if (i < 4) begin
                                if (j < 4) begin
                                    tp_sram_A_addr <= tile_i * 16 + i * 4 + j;
                                    tp_sram_B_addr <= tile_j * 16 + i * 4 + j;
                                    tp_sram_A_ce <= 1;
                                    tp_sram_B_ce <= 1;
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
                                tp_sram_A_ce <= 0;
                                tp_sram_B_ce <= 0;
                            end
                        end
                        CONV: begin
                            if (i < 6) begin
                                if (j < 6) begin
                                    tp_sram_A_addr <= tile_i * 36 + i * 6 + j;
                                    if (i < 3 && j < 3)
                                        tp_sram_B_addr <= tile_j * 9 + i * 3 + j;
                                    tp_sram_A_ce <= 1;
                                    tp_sram_B_ce <= (i < 3 && j < 3);
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
                                tp_sram_A_ce <= 0;
                                tp_sram_B_ce <= 0;
                            end
                        end
                        DOT: begin
                            if (i < 16) begin
                                tp_sram_A_addr <= tile_i * 16 + i;
                                tp_sram_B_addr <= tile_j * 16 + i;
                                tp_sram_A_ce <= 1;
                                tp_sram_B_ce <= 1;
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
                                tp_sram_A_ce <= 0;
                                tp_sram_B_ce <= 0;
                            end
                        end
                    endcase
                end
                COMPUTE: begin
                    if (op_done) begin
                        state <= DONE;
                        i <= 0;
                        j <= 0;
                        write_count <= 0;
                        $display("Debug: COMPUTE to DONE, op_done=%b", op_done);
                    end
                end
                DONE: begin
                    if (op_code == DOT) begin
                        if (write_count < 4) begin
                            tp_sram_C_addr <= tile_i * 32 + write_count;
                            tp_sram_C_we <= 1;
                            tp_sram_C_ce <= 1;
                            tp_sram_C_din <= final_result[0][write_count];
                            write_count <= write_count + 1;
                            $display("Debug: DONE state, op_code=DOT, write_count=%0d, we=%b, ce=%b, din=%h",
                                     write_count, tp_sram_C_we, tp_sram_C_ce, tp_sram_C_din);
                        end else begin
                            done <= 1;
                            state <= IDLE;
                            write_count <= 0;
                            tp_sram_C_we <= 0;
                            tp_sram_C_ce <= 0;
                            $display("Debug: DONE to IDLE, op_code=DOT, write_count=%0d", write_count);
                        end
                    end else begin
                        if (write_count < 16) begin
                            tp_sram_C_addr <= tile_i * 16 + write_count;
                            tp_sram_C_we <= 1;
                            tp_sram_C_ce <= 1;
                            tp_sram_C_din <= final_result[write_count/4][write_count%4];
                            write_count <= write_count + 1;
                            $display("Debug: DONE state, op_code=%0d, write_count=%0d, we=%b, ce=%b, din=%h",
                                     op_code, write_count, tp_sram_C_we, tp_sram_C_ce, tp_sram_C_din);
                        end else begin
                            done <= 1;
                            state <= IDLE;
                            write_count <= 0;
                            tp_sram_C_we <= 0;
                            tp_sram_C_ce <= 0;
                            $display("Debug: DONE to IDLE, op_code=%0d, write_count=%0d", op_code, write_count);
                        end
                    end
                end
            endcase
        end
    end
endmodule