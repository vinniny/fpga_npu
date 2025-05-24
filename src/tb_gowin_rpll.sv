module tb_gowin_rpll;
    logic clkout, lock, clkin;

    Gowin_rPLL_100mhz dut (
        .clkout(clkout), .lock(lock), .clkin(clkin)
    );

    initial begin
        clkin = 0;
        forever #18.52 clkin = ~clkin; // 27 MHz
    end

    initial begin
        #1000;
        if (lock)
            $display("rPLL: Lock achieved");
        else
            $display("rPLL: Lock failed");
        // Check clkout period (~21.164 ns)
        #100 $finish;
    end
endmodule