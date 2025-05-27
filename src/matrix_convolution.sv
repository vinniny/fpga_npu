(* use_dsp = "hard" *)
module matrix_convolution (
(* syn_keep = 1 *)     input logic clk, rst_n, start,
    input logic signed [7:0] input_tile [0:5][0:5],
    input logic signed [7:0] kernel [0:2][0:2],
(* syn_keep = 1 *)     output logic signed [15:0] c [0:3][0:3],
(* syn_keep = 1 *)     output logic signed [17:0] dsp_a0 [0:4], dsp_b0 [0:4],
(* syn_keep = 1 *)     input logic signed [36:0] dsp_out [0:4],
(* syn_keep = 1 *)     output logic dsp_ce,
(* syn_keep = 1 *)     output logic done
);
    logic [2:0] m, n;
    logic [4:0] mul_count;
(* syn_keep = 1 *)     logic computing, start_reg;
(* syn_keep = 1 *)     logic signed [17:0] dsp_a0_pre [0:4], dsp_b0_pre [0:4];
    logic signed [15:0] sum [0:3][0:3];
    logic [2:0] dsp_idx;

    assign dsp_ce = computing;

    // Register start signal on posedge clk with double sync
(* syn_keep = 1 *)     logic start_d;
// REVIEW: ensure proper 'end' for always block
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            start_d <= 0;
            start_reg <= 0;
        end else begin
            start_d <= start;
            start_reg <= start_d;
        end
    end

    // DSP input assignments
// REVIEW: ensure proper 'end' for always block
    always_comb begin
        dsp_a0_pre = '{default: 0};
        dsp_b0_pre = '{default: 0};
        if (computing && mul_count < 9) begin
            case (mul_count)
                0: begin
                    dsp_a0_pre[0] = {{10{input_tile[m][n][7]}}, input_tile[m][n]};
                    dsp_b0_pre[0] = {{10{kernel[0][0][7]}}, kernel[0][0]};
                end
                1: begin
                    dsp_a0_pre[1] = {{10{input_tile[m][n+1][7]}}, input_tile[m][n+1]};
                    dsp_b0_pre[1] = {{10{kernel[0][1][7]}}, kernel[0][1]};
                end
                2: begin
                    dsp_a0_pre[2] = {{10{input_tile[m][n+2][7]}}, input_tile[m][n+2]};
                    dsp_b0_pre[2] = {{10{kernel[0][2][7]}}, kernel[0][2]};
                end
                3: begin
                    dsp_a0_pre[3] = {{10{input_tile[m+1][n][7]}}, input_tile[m+1][n]};
                    dsp_b0_pre[3] = {{10{kernel[1][0][7]}}, kernel[1][0]};
                end
                4: begin
                    dsp_a0_pre[4] = {{10{input_tile[m+1][n+1][7]}}, input_tile[m+1][n+1]};
                    dsp_b0_pre[4] = {{10{kernel[1][1][7]}}, kernel[1][1]};
                end
                5: begin
                    dsp_a0_pre[0] = {{10{input_tile[m+1][n+2][7]}}, input_tile[m+1][n+2]};
                    dsp_b0_pre[0] = {{10{kernel[1][2][7]}}, kernel[1][2]};
                end
                6: begin
                    dsp_a0_pre[1] = {{10{input_tile[m+2][n][7]}}, input_tile[m+2][n]};
                    dsp_b0_pre[1] = {{10{kernel[2][0][7]}}, kernel[2][0]};
                end
                7: begin
                    dsp_a0_pre[2] = {{10{input_tile[m+2][n+1][7]}}, input_tile[m+2][n+1]};
                    dsp_b0_pre[2] = {{10{kernel[2][1][7]}}, kernel[2][1]};
                end
                8: begin
                    dsp_a0_pre[3] = {{10{input_tile[m+2][n+2][7]}}, input_tile[m+2][n+2]};
                    dsp_b0_pre[3] = {{10{kernel[2][2][7]}}, kernel[2][2]};
                end
                default: begin
                    dsp_a0_pre = '{default: 0};
                    dsp_b0_pre = '{default: 0};
                end
            endcase
        end
    end

    // DSP input pipeline
// REVIEW: ensure proper 'end' for always block
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for (int i = 0; i < 5; i++) begin
                dsp_a0[i] <= 0;
                dsp_b0[i] <= 0;
            end
        end else if (dsp_ce) begin
            dsp_a0 <= dsp_a0_pre;
            dsp_b0 <= dsp_b0_pre;
        end
    end

    // FSM and accumulation
// REVIEW: ensure proper 'end' for always block
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            m <= 0; n <= 0; mul_count <= 0; computing <= 0; done <= 0;
            dsp_idx <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++) begin
                    sum[x][y] <= 0;
                    c[x][y] <= 0;
                end
        end else begin
            if (start_reg && !computing && !done) begin
                computing <= 1;
                m <= 0; n <= 0; mul_count <= 0; done <= 0;
                dsp_idx <= 0;
                for (int x = 0; x < 4; x++)
                    for (int y = 0; y < 4; y++) begin
                        sum[x][y] <= 0;
                        c[x][y] <= 0;
                    end
            end else if (computing) begin
                mul_count <= mul_count + 1;
                if (mul_count >= 3 && mul_count < 12) begin
                    sum[m][n] <= sum[m][n] + $signed(dsp_out[dsp_idx][15:0]);
                    dsp_idx <= (dsp_idx == 4) ? 0 : dsp_idx + 1;
                end
                if (mul_count == 12) begin
                    c[m][n] <= sum[m][n];
                    sum[m][n] <= 0;
                    mul_count <= 0;
                    dsp_idx <= 0;
                    if (m < 3) begin
                        m <= m + 1;
                    end else if (n < 3) begin
                        m <= 0;
                        n <= n + 1;
                    end else begin
                        done <= 1;
                        computing <= 0;
                    end
                end
            end
        end
    end
endmodule