module matrix_addition (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:3][0:3], b [0:3][0:3],
    output logic [15:0] c [0:3][0:3],
    output logic done
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            done <= 0;
            for (int i = 0; i < 4; i++)
                for (int j = 0; j < 4; j++)
                    c[i][j] <= 0;
        end else if (start) begin
            for (int i = 0; i < 4; i++)
                for (int j = 0; j < 4; j++)
                    c[i][j] <= {8'd0, a[i][j]} + {8'd0, b[i][j]};
            done <= 1;
        end
    end
endmodule