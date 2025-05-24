module tb_sram_C;
    logic sram_C_we, rpll_clk;
    logic [7:0] sram_C_din, sram_C_dout;
    logic [9:0] sram_C_addr;

    sram_C dut (
        .sram_C_we(sram_C_we), .rpll_clk(rpll_clk), .sram_C_din(sram_C_din),
        .sram_C_addr(sram_C_addr), .sram_C_dout(sram_C_dout)
    );

    initial begin
        rpll_clk = 0;
        forever #10.58 rpll_clk = ~rpll_clk; // 47.25 MHz
    end

    initial begin
        sram_C_we = 0; sram_C_din = 8'h00; sram_C_addr = 10'd0;
        #100;
        // Write
        sram_C_we = 1; sram_C_din = 8'hCC; sram_C_addr = 10'd0;
        #20 sram_C_we = 0;
        // Read
        sram_C_addr = 10'd0;
        #20;
        if (sram_C_dout == 8'hCC)
            $display("SRAM C: Read %h, correct", sram_C_dout);
        else
            $display("SRAM C: Read %h, incorrect", sram_C_dout);
        #100 $finish;
    end
endmodule