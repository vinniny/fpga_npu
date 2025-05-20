```verilog
module tb_matrix_convolution;
    logic clk = 0, rst_n = 0, start = 0;
    logic [7:0] input_tile [0:5][0:5], kernel [0:2][0:2];
    logic [15:0] c [0:3][0:3];
    logic [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    logic [36:0] dsp_out [0:4];
    logic dsp_ce, done;

    always #10 clk = ~clk; // 50 MHz

    matrix_convolution dut (
        .clk(clk), .rst_n(rst_n), .start(start), .input_tile(input_tile),
        .kernel(kernel), .c(c), .dsp_a0(dsp_a0), .dsp_b0(dsp_b0),
        .dsp_out(dsp_out), .dsp_ce(dsp_ce), .done(done)
    );

    initial begin
        rst_n = 0; #20; rst_n = 1;
        for (int x = 0; x < 6; x++)
            for (int y = 0; y < 6; y++)
                input_tile[x][y] = x + y + 1;
        kernel = '{'{1,0,0}, '{0,1,0}, '{0,0,1}}; // Identity kernel
        start = 1; #20; start = 0;
        wait (done);
        $display("C[0][0] = %d", c[0][0]);
        $finish;
    end

    always @(posedge clk) begin
        for (int z = 0; z < 5; z++)
            dsp_out[z] <= dsp_a0[z] * dsp_b0[z];
    end
endmodule
```