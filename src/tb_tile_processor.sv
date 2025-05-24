module tb_tile_processor;
    logic clk, rst_n, start, tp_sram_A_we, tp_sram_B_we, tp_sram_C_we, done;
    logic [2:0] tile_i, tile_j, op_code;
    logic [7:0] sram_A_dout, sram_B_dout;
    logic [9:0] tp_sram_A_addr, tp_sram_B_addr, tp_sram_C_addr;
    logic [7:0] tp_sram_A_din, tp_sram_B_din, tp_sram_C_din;

    tile_processor dut (
        .clk(clk), .rst_n(rst_n), .start(start), .tile_i(tile_i), .tile_j(tile_j),
        .op_code(op_code), .sram_A_dout(sram_A_dout), .sram_B_dout(sram_B_dout),
        .tp_sram_A_we(tp_sram_A_we), .tp_sram_B_we(tp_sram_B_we), .tp_sram_C_we(tp_sram_C_we),
        .tp_sram_A_addr(tp_sram_A_addr), .tp_sram_B_addr(tp_sram_B_addr), .tp_sram_C_addr(tp_sram_C_addr),
        .tp_sram_A_din(tp_sram_A_din), .tp_sram_B_din(tp_sram_B_din), .tp_sram_C_din(tp_sram_C_din),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #10.58 clk = ~clk; // 47.25 MHz
    end

    initial begin
        rst_n = 0; start = 0; tile_i = 0; tile_j = 0; op_code = 0; sram_A_dout = 8'h00; sram_B_dout = 8'h00;
        #100 rst_n = 1;
        // Test MUL operation
        op_code = 3'd0; // MUL
        start = 1;
        #20 start = 0;
        // Simulate SRAM reads
        repeat (64) begin
            sram_A_dout = 8'h01; sram_B_dout = 8'h02;
            #20;
        end
        wait (done);
        $display("Tile Processor: MUL done, sram_C_din = %h", tp_sram_C_din);
        #100 $finish;
    end
endmodule