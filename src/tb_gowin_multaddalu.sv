module tb_gowin_multaddalu;
    logic ce, clk, reset;
    logic [17:0] a0, b0, a1, b1;
    logic [36:0] dout;
    logic [54:0] caso;

    Gowin_MULTADDALU dut (
        .dout(dout), .caso(caso), .a0(a0), .b0(b0), .a1(a1), .b1(b1),
        .ce(ce), .clk(clk), .reset(reset)
    );

    initial begin
        clk = 0;
        forever #10.58 clk = ~clk; // 47.25 MHz
    end

    initial begin
        reset = 1; ce = 0; a0 = 0; b0 = 0; a1 = 0; b1 = 0;
        #100 reset = 0;
        #20 ce = 1;
        a0 = 18'h0001; b0 = 18'h0002; // 1 * 2
        #40;
        if (dout[15:0] == 16'h0002)
            $display("MULTADDALU: dout = %h, correct", dout[15:0]);
        else
            $display("MULTADDALU: dout = %h, incorrect", dout[15:0]);
        #100 $finish;
    end
endmodule