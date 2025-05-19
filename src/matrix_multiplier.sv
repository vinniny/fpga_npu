module matrix_multiplier (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:3][0:31],
    input logic [7:0] b [0:31][0:3],
    output logic [15:0] c [0:3][0:3],
    output logic done
);
    logic [3:0] k; // Widened to 4 bits
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
            k <= 0; done <= 0; computing <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++) begin
                    dsp_a0[x][y] <= 0;
                    dsp_b0[x][y] <= 0;
                    c[x][y] <= 0;
                end
        end else if (start && !computing) begin
            computing <= 1;
            k <= 0;
        end else if (computing) begin
            // Assign inputs to all 16 DSPs
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++) begin
                    dsp_a0[x][y] <= {10'd0, a[x][k]};
                    dsp_b0[x][y] <= {10'd0, b[k][y]};
                    c[x][y] <= dsp_out[x][y][15:0];
                end
            if (k < 31) begin // 32 iterations (0 to 31)
                k <= k + 1;
            end else begin
                done <= 1;
                computing <= 0;
            end
        end
    end
endmodule