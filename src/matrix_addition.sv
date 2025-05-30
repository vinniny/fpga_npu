module matrix_addition (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:3][0:3],
    input logic [7:0] b [0:3][0:3],
    output logic [15:0] c [0:3][0:3],
    output logic done
);
    logic [2:0] i, j;
    logic computing;
    logic [15:0] c_next [0:3][0:3];

    // Rewritten combinational logic
    always_comb begin
        for (int x = 0; x < 4; x++)
            for (int y = 0; y < 4; y++)
                c_next[x][y] = computing && x == i && y == j ? a[x][y] + b[x][y] : c[x][y];
    end

    // Unchanged sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i <= 0; j <= 0; done <= 0; computing <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++)
                    c[x][y] <= 0;
        end else if (start && !computing) begin
            computing <= 1;
            i <= 0; j <= 0;
        end else if (computing) begin
            if (i < 4 && j < 4) begin
                c[i][j] <= c_next[i][j];
                j <= 3'(j + 1);
            end else if (i < 4) begin
                i <= 3'(i + 1);
                j <= 0;
            end else begin
                done <= 1;
                computing <= 0;
            end
        end
    end
endmodule