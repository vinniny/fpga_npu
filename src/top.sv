module top (
    input logic clk, rst_n, sclk, mosi, cs_n,
    output logic miso, done
);
    logic rpll_clk; // 100 MHz clock
    logic pll_lock; // PLL lock signal

    // Instantiate rPLL for 50 MHz to 100 MHz
    Gowin_rPLL_100mhz pll_inst (
        .clkout(rpll_clk), // 100 MHz output
        .lock(pll_lock),   // PLL lock signal
        .clkin(clk)        // 50 MHz input
    );

    // Synchronize reset with PLL lock
    logic rst_n_sync;
    always_ff @(posedge rpll_clk or negedge rst_n) begin
        if (!rst_n)
            rst_n_sync <= 0;
        else
            rst_n_sync <= pll_lock;
    end

    top_npu_system npu_inst (
        .clk(rpll_clk),
        .rst_n(rst_n_sync),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .miso(miso),
        .done(done)
    );
endmodule
