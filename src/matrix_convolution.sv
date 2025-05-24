(* use_dsp = "hard" *)
module matrix_convolution (
    input logic clk, rst_n, start,
    input logic [7:0] input_tile [0:5][0:5],
    input logic [7:0] kernel [0:2][0:2],
    output logic [15:0] c [0:3][0:3],
    output logic [17:0] dsp_a0 [0:4], dsp_b0 [0:4],
    input logic [36:0] dsp_out [0:4],
    output logic dsp_ce,
    output logic done
);
    (* keep = "true" *) logic [2:0] m, n;
    (* keep = "true" *) logic [15:0] c [0:3][0:3];
    logic [2:0] iter;
    logic computing;
    logic [2:0] row_idx, col_idx;

    assign row_idx = m;
    assign col_idx = n;
    assign dsp_ce = computing;

    always_comb begin
        dsp_a0 = '{default: 0};
        dsp_b0 = '{default: 0};
        if (computing) begin
            case (iter)
                0: begin
                    dsp_a0[0] = {10'd0, input_tile[row_idx][col_idx]};
                    dsp_a0[1] = {10'd0, input_tile[row_idx][col_idx+1]};
                    dsp_a0[2] = {10'd0, input_tile[row_idx][col_idx+2]};
                    dsp_a0[3] = {10'd0, input_tile[row_idx][col_idx+3]};
                    dsp_a0[4] = {10'd0, input_tile[row_idx+1][col_idx]};
                end
                1: begin
                    dsp_a0[0] = {10'd0, input_tile[row_idx+1][col_idx+1]};
                    dsp_a0[1] = {10'd0, input_tile[row_idx+1][col_idx+2]};
                    dsp_a0[2] = {10'd0, input_tile[row_idx+1][col_idx+3]};
                    dsp_a0[3] = {10'd0, input_tile[row_idx+2][col_idx]};
                    dsp_a0[4] = {10'd0, input_tile[row_idx+2][col_idx+1]};
                end
                2: begin
                    dsp_a0[0] = {10'd0, input_tile[row_idx+2][col_idx+2]};
                    dsp_a0[1] = {10'd0, input_tile[row_idx+2][col_idx+3]};
                    dsp_a0[2] = {10'd0, input_tile[row_idx+3][col_idx]};
                    dsp_a0[3] = {10'd0, input_tile[row_idx+3][col_idx+1]};
                    dsp_a0[4] = {10'd0, input_tile[row_idx+3][col_idx+2]};
                end
                3: dsp_a0[0] = {10'd0, input_tile[row_idx+3][col_idx+3]};
            endcase
            for (int z = 0; z < 5; z++)
                dsp_b0[z] = (iter <= 2 || z == 0) ? {10'd0, kernel[m][n]} : 0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            m <= 0; n <= 0; iter <= 0; done <= 0; computing <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++)
                    c[x][y] <= 0;
        end else if (start && !computing) begin
            computing <= 1;
            m <= 0; n <= 0; iter <= 0;
        end else if (computing) begin
            case (iter)
                0: begin
                    c[0][0] <= c[0][0] + dsp_out[0][15:0]; c[0][1] <= c[0][1] + dsp_out[1][15:0];
                    c[0][2] <= c[0][2] + dsp_out[2][15:0]; c[0][3] <= c[0][3] + dsp_out[3][15:0];
                    c[1][0] <= c[1][0] + dsp_out[4][15:0];
                end
                1: begin
                    c[1][1] <= c[1][1] + dsp_out[0][15:0]; c[1][2] <= c[1][2] + dsp_out[1][15:0];
                    c[1][3] <= c[1][3] + dsp_out[2][15:0]; c[2][0] <= c[2][0] + dsp_out[3][15:0];
                    c[2][1] <= c[2][1] + dsp_out[4][15:0];
                end
                2: begin
                    c[2][2] <= c[2][2] + dsp_out[0][15:0]; c[2][3] <= c[2][3] + dsp_out[1][15:0];
                    c[3][0] <= c[3][0] + dsp_out[2][15:0]; c[3][1] <= c[3][1] + dsp_out[3][15:0];
                    c[3][2] <= c[3][2] + dsp_out[4][15:0];
                end
                3: c[3][3] <= c[3][3] + dsp_out[0][15:0];
            endcase
            if (m < 2 || (m == 2 && n < 2)) begin
                if (n < 2) n <= 3'(n + 1);
                else begin
                    m <= 3'(m + 1);
                    n <= 0;
                end
            end else if (iter < 3) begin
                iter <= 3'(iter + 1);
                m <= 0; n <= 0;
            end else begin
                done <= 1;
                computing <= 0;
            end
        end
    end
endmodule