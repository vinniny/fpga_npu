module tb_sram_B;
    logic sram_B_we, rpll_clk;
    logic [7:0] sram_B_din, sram_B_dout;
    logic [9:0] sram_B_addr;

    sram_B dut (
        .sram_B_we(sram_B_we), .rpll_clk(rpll_clk), .sram_B_din(sram_B_din),
        .sram_B_addr(sram_B_addr), .sram_B_dout(sram_B_dout)
    );

    initial begin
        rpll_clk = 0;
        forever #10.58 rpll_clk = ~rpll_clk; // 47.25 MHz
    end

    initial begin
        sram_B_we = 0; sram_B_din = 8'h00; sram_B_addr = 10'd0;
        #100;
        // Write
        sram_B_we = 1; sram_B_din = 8'hBB; sram_B_addr = 10'd0;
        #20 sram_B_we = 0;
        // Read
        sram_B_addr = 10'd0;
        #20;
        if (sram_B_dout == 8'hBB)
            $display("SRAM B: Read %h, correct", sram_B_dout);
        else
            $display("SRAM B: Read %h, incorrect", sram_B_dout);
        #100 $finish;
    end
endmodule