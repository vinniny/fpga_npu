module tb_sram_A;
    logic sram_A_we, rpll_clk;
    logic [7:0] sram_A_din, sram_A_dout;
    logic [9:0] sram_A_addr;

    sram_A dut (
        .sram_A_we(sram_A_we), .rpll_clk(rpll_clk), .sram_A_din(sram_A_din),
        .sram_A_addr(sram_A_addr), .sram_A_dout(sram_A_dout)
    );

    initial begin
        rpll_clk = 0;
        forever #10.58 rpll_clk = ~rpll_clk; // 47.25 MHz
    end

    initial begin
        sram_A_we = 0; sram_A_din = 8'h00; sram_A_addr = 10'd0;
        #100;
        // Write
        sram_A_we = 1; sram_A_din = 8'hAA; sram_A_addr = 10'd0;
        #20 sram_A_we = 0;
        // Read
        sram_A_addr = 10'd0;
        #20;
        if (sram_A_dout == 8'hAA)
            $display("SRAM A: Read %h, correct", sram_A_dout);
        else
            $display("SRAM A: Read %h, incorrect", sram_A_dout);
        #100 $finish;
    end
endmodule