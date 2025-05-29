module matrix_subtraction (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:3][0:3],
    input logic [7:0] b [0:3][0:3],
    output logic [15:0] c [0:3][0:3],
    output logic done
);
    logic [2:0] i, j;
    logic computing;
    logic [15:0] c_next [0:3][0:3]; // Declare c_next

    // Compute subtraction directly
    always_comb begin
        for (int x = 0; x < 4; x++)
            for (int y = 0; y < 4; y++)
                c_next[x][y] = $signed({1'b0, a[x][y]}) - $signed({1'b0, b[x][y]});
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i <= 0; j <= 0; done <= 0; computing <= 0;
            for (int x = 0; x < 4; x++)
                for (int y = 0; y < 4; y++)
                    c[x][y] <= 0;
        end else begin
            if (start && !computing && !done) begin
                computing <= 1;
                i <= 0; j <= 0;
                for (int x = 0; x < 4; x++)
                    for (int y = 0; y < 4; y++)
                        c[x][y] <= 0; // Clear c on start
            end else if (computing) begin
                if (i < 4 && j < 4) begin
                    c[i][j] <= c_next[i][j];
                    j <= j + 1;
                    if (j == 3) begin
                        j <= 0;
                        i <= i + 1;
                    end
                end
                if (i == 3 && j == 3) begin
                    done <= 1;
                    computing <= 0;
                end
            end else if (done && !start) begin
                done <= 0; // Clear done when start is low
            end
        end
    end
endmodule