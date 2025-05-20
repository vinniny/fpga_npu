module matrix_convolution (
    input logic clk, rst_n, start,
    input logic [7:0] input_tile [0:19][0:5], // Fixed 7:8 to 7:0
    input logic [7:0] kernel [0:2][0:2],
    output logic [15:0] c [0:15][0:3],
    output logic [17:0] dsp_a0 [0:15], dsp_b0 [0:15],
    input logic [36:0] dsp_out [0:15],
    output logic dsp_ce,
    output logic done
);
    logic [4:0] m, n; // Widened to 5 bits
    logic [1:0] iter;
    logic computing;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            m <= 0; n <= 0; iter <= 0; done <= 0; computing <= 0; dsp_ce <= 0;
            for (int x = 0; x < 16; x++)
                for (int y = 0; y < 4; y++)
                    c[x][y] <= 0;
            for (int z = 0; z < 16; z++) begin
                dsp_a0[z] <= 0;
                dsp_b0[z] <= 0;
            end
        end else if (start && !computing) begin
            computing <= 1;
            m <= 0; n <= 0; iter <= 0;
            dsp_ce <= 1;
        end else if (computing) begin
            case (iter)
                0: begin // Tile 1: c[0:3][0:3]
                    dsp_a0[0] <= {10'd0, input_tile[0+m][0+n]}; dsp_b0[0] <= {10'd0, kernel[m][n]};
                    dsp_a0[1] <= {10'd0, input_tile[0+m][1+n]}; dsp_b0[1] <= {10'd0, kernel[m][n]};
                    dsp_a0[2] <= {10'd0, input_tile[0+m][2+n]}; dsp_b0[2] <= {10'd0, kernel[m][n]};
                    dsp_a0[3] <= {10'd0, input_tile[0+m][3+n]}; dsp_b0[3] <= {10'd0, kernel[m][n]};
                    dsp_a0[4] <= {10'd0, input_tile[1+m][0+n]}; dsp_b0[4] <= {10'd0, kernel[m][n]};
                    dsp_a0[5] <= {10'd0, input_tile[1+m][1+n]}; dsp_b0[5] <= {10'd0, kernel[m][n]};
                    dsp_a0[6] <= {10'd0, input_tile[1+m][2+n]}; dsp_b0[6] <= {10'd0, kernel[m][n]};
                    dsp_a0[7] <= {10'd0, input_tile[1+m][3+n]}; dsp_b0[7] <= {10'd0, kernel[m][n]};
                    dsp_a0[8] <= {10'd0, input_tile[2+m][0+n]}; dsp_b0[8] <= {10'd0, kernel[m][n]};
                    dsp_a0[9] <= {10'd0, input_tile[2+m][1+n]}; dsp_b0[9] <= {10'd0, kernel[m][n]};
                    dsp_a0[10] <= {10'd0, input_tile[2+m][2+n]}; dsp_b0[10] <= {10'd0, kernel[m][n]};
                    dsp_a0[11] <= {10'd0, input_tile[2+m][3+n]}; dsp_b0[11] <= {10'd0, kernel[m][n]};
                    dsp_a0[12] <= {10'd0, input_tile[3+m][0+n]}; dsp_b0[12] <= {10'd0, kernel[m][n]};
                    dsp_a0[13] <= {10'd0, input_tile[3+m][1+n]}; dsp_b0[13] <= {10'd0, kernel[m][n]};
                    dsp_a0[14] <= {10'd0, input_tile[3+m][2+n]}; dsp_b0[14] <= {10'd0, kernel[m][n]};
                    dsp_a0[15] <= {10'd0, input_tile[3+m][3+n]}; dsp_b0[15] <= {10'd0, kernel[m][n]};
                    c[0][0] <= dsp_out[0][15:0]; c[0][1] <= dsp_out[1][15:0];
                    c[0][2] <= dsp_out[2][15:0]; c[0][3] <= dsp_out[3][15:0];
                    c[1][0] <= dsp_out[4][15:0]; c[1][1] <= dsp_out[5][15:0];
                    c[1][2] <= dsp_out[6][15:0]; c[1][3] <= dsp_out[7][15:0];
                    c[2][0] <= dsp_out[8][15:0]; c[2][1] <= dsp_out[9][15:0];
                    c[2][2] <= dsp_out[10][15:0]; c[2][3] <= dsp_out[11][15:0];
                    c[3][0] <= dsp_out[12][15:0]; c[3][1] <= dsp_out[13][15:0];
                    c[3][2] <= dsp_out[14][15:0]; c[3][3] <= dsp_out[15][15:0];
                end
                1: begin // Tile 2: c[4:7][0:3]
                    dsp_a0[0] <= {10'd0, input_tile[4+m][0+n]}; dsp_b0[0] <= {10'd0, kernel[m][n]};
                    dsp_a0[1] <= {10'd0, input_tile[4+m][1+n]}; dsp_b0[1] <= {10'd0, kernel[m][n]};
                    dsp_a0[2] <= {10'd0, input_tile[4+m][2+n]}; dsp_b0[2] <= {10'd0, kernel[m][n]};
                    dsp_a0[3] <= {10'd0, input_tile[4+m][3+n]}; dsp_b0[3] <= {10'd0, kernel[m][n]};
                    dsp_a0[4] <= {10'd0, input_tile[5+m][0+n]}; dsp_b0[4] <= {10'd0, kernel[m][n]};
                    dsp_a0[5] <= {10'd0, input_tile[5+m][1+n]}; dsp_b0[5] <= {10'd0, kernel[m][n]};
                    dsp_a0[6] <= {10'd0, input_tile[5+m][2+n]}; dsp_b0[6] <= {10'd0, kernel[m][n]};
                    dsp_a0[7] <= {10'd0, input_tile[5+m][3+n]}; dsp_b0[7] <= {10'd0, kernel[m][n]};
                    dsp_a0[8] <= {10'd0, input_tile[6+m][0+n]}; dsp_b0[8] <= {10'd0, kernel[m][n]};
                    dsp_a0[9] <= {10'd0, input_tile[6+m][1+n]}; dsp_b0[9] <= {10'd0, kernel[m][n]};
                    dsp_a0[10] <= {10'd0, input_tile[6+m][2+n]}; dsp_b0[10] <= {10'd0, kernel[m][n]};
                    dsp_a0[11] <= {10'd0, input_tile[6+m][3+n]}; dsp_b0[11] <= {10'd0, kernel[m][n]};
                    dsp_a0[12] <= {10'd0, input_tile[7+m][0+n]}; dsp_b0[12] <= {10'd0, kernel[m][n]};
                    dsp_a0[13] <= {10'd0, input_tile[7+m][1+n]}; dsp_b0[13] <= {10'd0, kernel[m][n]};
                    dsp_a0[14] <= {10'd0, input_tile[7+m][2+n]}; dsp_b0[14] <= {10'd0, kernel[m][n]};
                    dsp_a0[15] <= {10'd0, input_tile[7+m][3+n]}; dsp_b0[15] <= {10'd0, kernel[m][n]};
                    c[4][0] <= dsp_out[0][15:0]; c[4][1] <= dsp_out[1][15:0];
                    c[4][2] <= dsp_out[2][15:0]; c[4][3] <= dsp_out[3][15:0];
                    c[5][0] <= dsp_out[4][15:0]; c[5][1] <= dsp_out[5][15:0];
                    c[5][2] <= dsp_out[6][15:0]; c[5][3] <= dsp_out[7][15:0];
                    c[6][0] <= dsp_out[8][15:0]; c[6][1] <= dsp_out[9][15:0];
                    c[6][2] <= dsp_out[10][15:0]; c[6][3] <= dsp_out[11][15:0];
                    c[7][0] <= dsp_out[12][15:0]; c[7][1] <= dsp_out[13][15:0];
                    c[7][2] <= dsp_out[14][15:0]; c[7][3] <= dsp_out[15][15:0];
                end
                2: begin // Tile 3: c[8:11][0:3]
                    dsp_a0[0] <= {10'd0, input_tile[8+m][0+n]}; dsp_b0[0] <= {10'd0, kernel[m][n]};
                    dsp_a0[1] <= {10'd0, input_tile[8+m][1+n]}; dsp_b0[1] <= {10'd0, kernel[m][n]};
                    dsp_a0[2] <= {10'd0, input_tile[8+m][2+n]}; dsp_b0[2] <= {10'd0, kernel[m][n]};
                    dsp_a0[3] <= {10'd0, input_tile[8+m][3+n]}; dsp_b0[3] <= {10'd0, kernel[m][n]};
                    dsp_a0[4] <= {10'd0, input_tile[9+m][0+n]}; dsp_b0[4] <= {10'd0, kernel[m][n]};
                    dsp_a0[5] <= {10'd0, input_tile[9+m][1+n]}; dsp_b0[5] <= {10'd0, kernel[m][n]};
                    dsp_a0[6] <= {10'd0, input_tile[9+m][2+n]}; dsp_b0[6] <= {10'd0, kernel[m][n]};
                    dsp_a0[7] <= {10'd0, input_tile[9+m][3+n]}; dsp_b0[7] <= {10'd0, kernel[m][n]};
                    dsp_a0[8] <= {10'd0, input_tile[10+m][0+n]}; dsp_b0[8] <= {10'd0, kernel[m][n]};
                    dsp_a0[9] <= {10'd0, input_tile[10+m][1+n]}; dsp_b0[9] <= {10'd0, kernel[m][n]};
                    dsp_a0[10] <= {10'd0, input_tile[10+m][2+n]}; dsp_b0[10] <= {10'd0, kernel[m][n]};
                    dsp_a0[11] <= {10'd0, input_tile[10+m][3+n]}; dsp_b0[11] <= {10'd0, kernel[m][n]};
                    dsp_a0[12] <= {10'd0, input_tile[11+m][0+n]}; dsp_b0[12] <= {10'd0, kernel[m][n]};
                    dsp_a0[13] <= {10'd0, input_tile[11+m][1+n]}; dsp_b0[13] <= {10'd0, kernel[m][n]};
                    dsp_a0[14] <= {10'd0, input_tile[11+m][2+n]}; dsp_b0[14] <= {10'd0, kernel[m][n]};
                    dsp_a0[15] <= {10'd0, input_tile[11+m][3+n]}; dsp_b0[15] <= {10'd0, kernel[m][n]};
                    c[8][0] <= dsp_out[0][15:0]; c[8][1] <= dsp_out[1][15:0];
                    c[8][2] <= dsp_out[2][15:0]; c[8][3] <= dsp_out[3][15:0];
                    c[9][0] <= dsp_out[4][15:0]; c[9][1] <= dsp_out[5][15:0];
                    c[9][2] <= dsp_out[6][15:0]; c[9][3] <= dsp_out[7][15:0];
                    c[10][0] <= dsp_out[8][15:0]; c[10][1] <= dsp_out[9][15:0];
                    c[10][2] <= dsp_out[10][15:0]; c[10][3] <= dsp_out[11][15:0];
                    c[11][0] <= dsp_out[12][15:0]; c[11][1] <= dsp_out[13][15:0];
                    c[11][2] <= dsp_out[14][15:0]; c[11][3] <= dsp_out[15][15:0];
                end
                3: begin // Tile 4: c[12:15][0:3]
                    dsp_a0[0] <= {10'd0, input_tile[12+m][0+n]}; dsp_b0[0] <= {10'd0, kernel[m][n]};
                    dsp_a0[1] <= {10'd0, input_tile[12+m][1+n]}; dsp_b0[1] <= {10'd0, kernel[m][n]};
                    dsp_a0[2] <= {10'd0, input_tile[12+m][2+n]}; dsp_b0[2] <= {10'd0, kernel[m][n]};
                    dsp_a0[3] <= {10'd0, input_tile[12+m][3+n]}; dsp_b0[3] <= {10'd0, kernel[m][n]};
                    dsp_a0[4] <= {10'd0, input_tile[13+m][0+n]}; dsp_b0[4] <= {10'd0, kernel[m][n]};
                    dsp_a0[5] <= {10'd0, input_tile[13+m][1+n]}; dsp_b0[5] <= {10'd0, kernel[m][n]};
                    dsp_a0[6] <= {10'd0, input_tile[13+m][2+n]}; dsp_b0[6] <= {10'd0, kernel[m][n]};
                    dsp_a0[7] <= {10'd0, input_tile[13+m][3+n]}; dsp_b0[7] <= {10'd0, kernel[m][n]};
                    dsp_a0[8] <= {10'd0, input_tile[14+m][0+n]}; dsp_b0[8] <= {10'd0, kernel[m][n]};
                    dsp_a0[9] <= {10'd0, input_tile[14+m][1+n]}; dsp_b0[9] <= {10'd0, kernel[m][n]};
                    dsp_a0[10] <= {10'd0, input_tile[14+m][2+n]}; dsp_b0[10] <= {10'd0, kernel[m][n]};
                    dsp_a0[11] <= {10'd0, input_tile[14+m][3+n]}; dsp_b0[11] <= {10'd0, kernel[m][n]};
                    dsp_a0[12] <= {10'd0, input_tile[15+m][0+n]}; dsp_b0[12] <= {10'd0, kernel[m][n]};
                    dsp_a0[13] <= {10'd0, input_tile[15+m][1+n]}; dsp_b0[13] <= {10'd0, kernel[m][n]};
                    dsp_a0[14] <= {10'd0, input_tile[15+m][2+n]}; dsp_b0[14] <= {10'd0, kernel[m][n]};
                    dsp_a0[15] <= {10'd0, input_tile[15+m][3+n]}; dsp_b0[15] <= {10'd0, kernel[m][n]};
                    c[12][0] <= dsp_out[0][15:0]; c[12][1] <= dsp_out[1][15:0];
                    c[12][2] <= dsp_out[2][15:0]; c[12][3] <= dsp_out[3][15:0];
                    c[13][0] <= dsp_out[4][15:0]; c[13][1] <= dsp_out[5][15:0];
                    c[13][2] <= dsp_out[6][15:0]; c[13][3] <= dsp_out[7][15:0];
                    c[14][0] <= dsp_out[8][15:0]; c[14][1] <= dsp_out[9][15:0];
                    c[14][2] <= dsp_out[10][15:0]; c[14][3] <= dsp_out[11][15:0];
                    c[15][0] <= dsp_out[12][15:0]; c[15][1] <= dsp_out[13][15:0];
                    c[15][2] <= dsp_out[14][15:0]; c[15][3] <= dsp_out[15][15:0];
                end
            endcase
            if (m < 2 || (m == 2 && n < 2)) begin
                if (n < 2) begin
                    n <= n + 1;
                end else begin
                    m <= m + 1; n <= 0;
                end
            end else if (iter < 3) begin
                iter <= iter + 1; m <= 0; n <= 0;
            end else begin
                done <= 1;
                computing <= 0;
                dsp_ce <= 0;
            end
        end
    end
endmodule