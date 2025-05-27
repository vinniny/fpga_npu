`timescale 1ns/1ps

module tb_matrix_convolution;

  logic clk, rst_n, start;
  logic signed [7:0] input_tile [0:5][0:5];
  logic signed [7:0] kernel [0:2][0:2];
  logic signed [15:0] c [0:3][0:3];
  logic signed [17:0] dsp_a0 [0:4], dsp_b0 [0:4];
  logic signed [36:0] dsp_out [0:4];
  logic dsp_ce;
  logic done;

  // Clock generation
  initial clk = 0;
  always #10 clk = ~clk;

  // DUT instantiation
  matrix_convolution dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .input_tile(input_tile),
    .kernel(kernel),
    .c(c),
    .dsp_a0(dsp_a0),
    .dsp_b0(dsp_b0),
    .dsp_out(dsp_out),
    .dsp_ce(dsp_ce),
    .done(done)
  );

  // Stimulus
  initial begin
    $display("Starting testbench for matrix_convolution...");
    rst_n = 0; start = 0;
    repeat(5) @(posedge clk);
    rst_n = 1;

    // Initialize inputs
    for (int i = 0; i < 6; i++)
      for (int j = 0; j < 6; j++)
        input_tile[i][j] = i + j;

    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        kernel[i][j] = 1;

    for (int i = 0; i < 5; i++)
      dsp_out[i] = 0;

    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;

    wait (done);
    $display("Convolution completed.");

    // Display result
    // Display result
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        $display("c[%0d][%0d] = %0d", i, j, c[i][j]);
      end
    end
    $finish;
  end
  // Emulate DSP behavior
  always @(posedge clk) begin
    if (dsp_ce) begin
      for (int i = 0; i < 5; i++) begin
        dsp_out[i] <= #1 dsp_a0[i] * dsp_b0[i];
      end
    end
  end
endmodule
