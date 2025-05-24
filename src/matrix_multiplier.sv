(* use_dsp = "hard" *)
module matrix_multiplier (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:3][0:15],
    input logic [7:0] b [0:15][0:3],
    output logic [15:0] c [0:3][0:3],
    output logic [17:0] dsp_a0 [0:4], dsp_b0 [0:4],
    input logic [36:0] dsp_out [0:4],
    output logic dsp_ce,
    output logic done
);
    logic [3:0] k; // 0 to 15, 4 bits
    logic [2:0] iter; // 0 to 3, 3 bits
    logic computing;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            k <= 0; iter <= 0; done <= 0; computing <= 0; dsp_ce <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++)
                    c[x][y] <= 0;
            for (int z = 0; z < 5; z++) begin
                dsp_a0[z] <= 0;
                dsp_b0[z] <= 0;
            end
        end else if (start && !computing) begin
            computing <= 1;
            k <= 0; iter <= 0;
            dsp_ce <= 1;
        end else if (computing) begin
            // Explicit combinational logic within sequential block
            case (iter)
                0: begin
                    dsp_a0[0] <= {10'd0, a[0][k]}; dsp_b0[0] <= {10'd0, b[k][0]}; // c[0][0]
                    dsp_a0[1] <= {10'd0, a[0][k]}; dsp_b0[1] <= {10'd0, b[k][1]}; // c[0][1]
                    dsp_a0[2] <= {10'd0, a[0][k]}; dsp_b0[2] <= {10'd0, b[k][2]}; // c[0][2]
                    dsp_a0[3] <= {10'd0, a[0][k]}; dsp_b0[3] <= {10'd0, b[k][3]}; // c[0][3]
                    dsp_a0[4] <= {10'd0, a[1][k]}; dsp_b0[4] <= {10'd0, b[k][0]}; // c[1][0]
                    c[0][0] <= c[0][0] + dsp_out[0][15:0]; c[0][1] <= c[0][1] + dsp_out[1][15:0];
                    c[0][2] <= c[0][2] + dsp_out[2][15:0]; c[0][3] <= c[0][3] + dsp_out[3][15:0];
                    c[1][0] <= c[1][0] + dsp_out[4][15:0];
                end
                1: begin
                    dsp_a0[0] <= {10'd0, a[1][k]}; dsp_b0[0] <= {10'd0, b[k][1]}; // c[1][1]
                    dsp_a0[1] <= {10'd0, a[1][k]}; dsp_b0[1] <= {10'd0, b[k][2]}; // c[1][2]
                    dsp_a0[2] <= {10'd0, a[1][k]}; dsp_b0[2] <= {10'd0, b[k][3]}; // c[1][3]
                    dsp_a0[3] <= {10'd0, a[2][k]}; dsp_b0[3] <= {10'd0, b[k][0]}; // c[2][0]
                    dsp_a0[4] <= {10'd0, a[2][k]}; dsp_b0[4] <= {10'd0, b[k][1]}; // c[2][1]
                    c[1][1] <= c[1][1] + dsp_out[0][15:0]; c[1][2] <= c[1][2] + dsp_out[1][15:0];
                    c[1][3] <= c[1][3] + dsp_out[2][15:0]; c[2][0] <= c[2][0] + dsp_out[3][15:0];
                    c[2][1] <= c[2][1] + dsp_out[4][15:0];
                end
                2: begin
                    dsp_a0[0] <= {10'd0, a[2][k]}; dsp_b0[0] <= {10'd0, b[k][2]}; // c[2][2]
                    dsp_a0[1] <= {10'd0, a[2][k]}; dsp_b0[1] <= {10'd0, b[k][3]}; // c[2][3]
                    dsp_a0[2] <= {10'd0, a[3][k]}; dsp_b0[2] <= {10'd0, b[k][0]}; // c[3][0]
                    dsp_a0[3] <= {10'd0, a[3][k]}; dsp_b0[3] <= {10'd0, b[k][1]}; // c[3][1]
                    dsp_a0[4] <= {10'd0, a[3][k]}; dsp_b0[4] <= {10'd0, b[k][2]}; // c[3][2]
                    c[2][2] <= c[2][2] + dsp_out[0][15:0]; c[2][3] <= c[2][3] + dsp_out[1][15:0];
                    c[3][0] <= c[3][0] + dsp_out[2][15:0]; c[3][1] <= c[3][1] + dsp_out[3][15:0];
                    c[3][2] <= c[3][2] + dsp_out[4][15:0];
                end
                3: begin
                    dsp_a0[0] <= {10'd0, a[3][k]}; dsp_b0[0] <= {10'd0, b[k][3]}; // c[3][3]
                    dsp_a0[1] <= 0; dsp_b0[1] <= 0;
                    dsp_a0[2] <= 0; dsp_b0[2] <= 0;
                    dsp_a0[3] <= 0; dsp_b0[3] <= 0;
                    dsp_a0[4] <= 0; dsp_b0[4] <= 0;
                    c[3][3] <= c[3][3] + dsp_out[0][15:0];
                end
            endcase
            if (k < 15) begin
                k <= 4'(k + 1);
            end else if (iter < 3) begin
                iter <= 3'(iter + 1);
                k <= 0;
            end else begin
                done <= 1;
                computing <= 0;
                dsp_ce <= 0;
            end
        end
    end
endmodule