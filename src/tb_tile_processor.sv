```verilog
module tb_tile_processor;
    logic clk = 0, rst_n = 0, start = 0;
    logic [2:0] tile_i = 0, tile_j = 0, op_code = 0;
    logic [7:0] sram_A_dout = 0, sram_B_dout = 0;
    logic tp_sram_A_we, tp_sram_B_we, tp_sram_C_we;
    logic [9:0] tp_sram_A_addr, tp_sram_B_addr, tp_sram_C_addr;
    logic [7:0] tp_sram_A_din, tp_sram_B_din, tp_sram_C_din;
    logic done;

    always #10 clk = ~clk; // 50 MHz

    tile_processor dut (
        .clk(clk), .rst_n(rst_n), .start(start), .tile_i(tile_i), .tile_j(tile_j),
        .op_code(op_code), .sram_A_dout(sram_A_dout), .sram_B_dout(sram_B_dout),
        .tp_sram_A_we(tp_sram_A_we), .tp_sram_B_we(tp_sram_B_we), .tp_sram_C_we(tp_sram_C_we),
        .tp_sram_A_addr(tp_sram_A_addr), .tp_sram_B_addr(tp_sram_B_addr), .tp_sram_C_addr(tp_sram_C_addr),
        .tp_sram_A_din(tp_sram_A_din), .tp_sram_B_din(tp_sram_B_din), .tp_sram_C_din(tp_sram_C_din),
        .done(done)
    );

    initial begin
        rst_n = 0; #20; rst_n = 1;
        op_code = 0; // MUL
        start = 1; #20; start = 0;
        wait (done);
        $display("Done: %b, A_addr: %d", done, tp_sram_A_addr);
        $finish;
    end

    always @(posedge clk) begin
        sram_A_dout <= $random % 256;
        sram_B_dout <= $random % 256;
    end
endmodule
```