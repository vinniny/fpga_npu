module tb_matrix_dot;
    logic clk, rst_n, start, done;
    logic [7:0] a [0:15], b [0:15];
    logic [15:0] c;

    matrix_dot dut (
        .clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b), .c(c), .done(done)
    );

    initial begin
        clk = 0;
        forever #10.58 clk = ~clk; // 47.25 MHz
    end

    initial begin
        rst_n = 0; start = 0;
        for (int i = 0; i < 16; i++) begin
            a[i] = 8'h01; b[i] = 8'h01;
        end
        #100 rst_n = 1;
        #20 start = 1;
        #20 start = 0;
        wait (done);
        $display("Matrix Dot: Done");
        if (c == 16'h10)
            $display("c = %h, correct", c);
        else
            $display("c = %h, incorrect", c);
        #100 $finish;
    end
endmodule