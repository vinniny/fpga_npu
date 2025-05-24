module tb_matrix_subtraction;
    logic clk, rst_n, start, done;
    logic [7:0] a [0:3][0:3], b [0:3][0:3];
    logic [15:0] c [0:3][0:3];

    matrix_subtraction dut (
        .clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b), .c(c), .done(done)
    );

    initial begin
        clk = 0;
        forever #10.58 clk = ~clk; // 47.25 MHz
    end

    initial begin
        rst_n = 0; start = 0;
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++) begin
                a[i][j] = 8'h03; b[i][j] = 8'h01;
            end
        #100 rst_n = 1;
        #20 start = 1;
        #20 start = 0;
        wait (done);
        $display("Matrix Subtraction: Done");
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                if (c[i][j] == 16'h02)
                    $display("c[%d][%d] = %h, correct", i, j, c[i][j]);
                else
                    $display("c[%d][%d] = %h, incorrect", i, j, c[i][j]);
        #100 $finish;
    end
endmodule