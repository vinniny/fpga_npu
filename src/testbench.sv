module testbench;
    logic clk = 0, rst_n = 0, start = 0;
    logic [7:0] a [0:3][0:31], b [0:31][0:3];
    logic [15:0] c [0:3][0:3];
    logic done;
    always #10 clk = ~clk; // 50 MHz
    matrix_multiplier dut (.clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b), .c(c), .done(done));
    initial begin
        rst_n = 0; #20; rst_n = 1;
        for (int x = 0; x < 4; x++)
            for (int k = 0; k < 32; k++) begin
                a[x][k] = k + 1;
                b[k][x] = k + 1;
            end
        start = 1; #20; start = 0;
        wait (done);
        $display("C[0][0] = %d", c[0][0]); // Expected: sum of (k+1)*(k+1) for k=0 to 31
        $finish;
    end
endmodule