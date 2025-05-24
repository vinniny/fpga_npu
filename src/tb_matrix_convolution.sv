module tb_matrix_convolution;
    logic clk, rst_n, start, dsp_ce, done;
    logic [7:8] input_tile [0:5][0:5], kernel [0:2][0:2];
    logic [15:0] c [0:3][0:3];
    logic [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
    logic [36:0] dsp_out [0:4];

    matrix_convolution dut (
        .clk(clk), .rst_n(rst_n), .start(start), .input_tile(input_tile), .kernel(kernel),
        .c(c), .dsp_a0(dsp_a0), .dsp_b0(dsp_b0), .dsp_out(dsp_out), .dsp_ce(dsp_ce), .done(done)
    );

    initial begin
        clk = 0;
        forever #10.58 clk = ~clk; // 47.25 MHz
    end

    // Simulate DSP output
    always_comb begin
        for (int z = 0; z < 5; z++)
            dsp_out[z] = dsp_ce ? {19'd0, dsp_a0[z][7:0] * dsp_b0[z][7:0]} : 0;
    end

    initial begin
        rst_n = 0; start = 0;
        for (int i = 0; i < 6; i++)
            for (int j = 0; j < 6; j++)
                input_tile[i][j] = 8'h01;
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                kernel[i][j] = 8'h01;
        #100 rst_n = 1;
        #20 start = 1;
        #20 start = 0;
        wait (done);
        $display("Matrix Convolution: Done");
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                if (c[i][j] == 16'h09)
                    $display("c[%d][%d] = %h, correct", i, j, c[i][j]);
                else
                    $display("c[%d][%d] = %h, incorrect", i, j, c[i][j]);
        #100 $finish;
    end
endmodule