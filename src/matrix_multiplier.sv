module matrix_multiplier (
    input clk, rst_n, start,
    input [7:0] a [0:3][0:31],
    input [7:0] b [0:31][0:3],
    output logic [15:0] c [0:3][0:3],
    output logic done
);
    logic [3:0] i; // Widened to 4 bits
    logic [2:0] j, k;
    logic computing;
    logic [17:0] dsp_a0, dsp_b0;
    logic [36:0] dsp_out;

    Gowin_MULTADDALU dsp_inst (
        .a0(dsp_a0),
        .b0(dsp_b0),
        .a1(18'd0),
        .b1(18'd0),
        .dout(dsp_out),
        .caso(),
        .ce(computing),
        .clk(clk),
        .reset(~rst_n)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i <= 0; j <= 0; k <= 0; done <= 0; computing <= 0;
            dsp_a0 <= 0; dsp_b0 <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++)
                    c[x][y] <= 0;
        end else if (start && !computing) begin
            computing <= 1;
        end else if (computing) begin
            dsp_a0 <= {10'd0, a[i][k]};
            dsp_b0 <= {10'd0, b[k][j]};
            c[i][j] <= dsp_out[15:0];
            if (k < 32) begin
                k <= k + 1;
            end else if (j < 3'd4) begin
                j <= j + 1; k <= 0;
            end else if (i < 4) begin
                i <= i + 1; j <= 0; k <= 0;
            end else begin
                done <= 1; computing <= 0;
            end
        end
    end
endmodule