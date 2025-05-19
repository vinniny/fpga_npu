module matrix_convolution (
    input logic clk, rst_n, start,
    input logic [7:0] input_tile [0:5][0:5],
    input logic [7:0] kernel [0:2][0:2],
    output logic [15:0] c [0:3][0:3],
    output logic done
);
    logic [3:0] m, n; // Widened to 4 bits
    logic computing;
    logic [17:0] dsp_a0 [0:3][0:3], dsp_b0 [0:3][0:3];
    logic [36:0] dsp_out [0:3][0:3];

    // Instantiate 16 DSPs for 4x4 MAC array
    genvar x, y;
    generate
        for (x = 0; x < 4; x++) begin : gen_x
            for (y = 0; y < 4; y++) begin : gen_y
                Gowin_MULTADDALU dsp_inst (
                    .a0(dsp_a0[x][y]),
                    .b0(dsp_b0[x][y]),
                    .a1(18'd0),
                    .b1(18'd0),
                    .dout(dsp_out[x][y]),
                    .caso(),
                    .ce(computing),
                    .clk(clk),
                    .reset(~rst_n)
                );
            end
        end
    endgenerate

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            m <= 0; n <= 0; done <= 0; computing <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++) begin
                    dsp_a0[x][y] <= 0;
                    dsp_b0[x][y] <= 0;
                    c[x][y] <= 0;
                end
        end else if (start && !computing) begin
            computing <= 1;
            m <= 0; n <= 0;
        end else if (computing) begin
            // Assign inputs to all 16 DSPs
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++) begin
                    dsp_a0[x][y] <= {10'd0, input_tile[x+m][y+n]};
                    dsp_b0[x][y] <= {10'd0, kernel[m][n]};
                    c[x][y] <= dsp_out[x][y][15:0];
                end
            if (m < 2 || (m == 2 && n < 2)) begin // 3x3 kernel (9 iterations)
                if (n < 2) begin
                    n <= n + 1;
                end else begin
                    m <= m + 1; n <= 0;
                end
            end else begin
                done <= 1;
                computing <= 0;
            end
        end
    end
endmodule