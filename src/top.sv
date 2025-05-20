module top (
    input logic clk, rst_n, sclk, mosi, cs_n,
    output logic miso, done
);
    logic clk_100M; // 100 MHz clock
    logic pll_lock;

    // Instantiate Gowin_rPLL_100mhz
    Gowin_rPLL_100mhz pll_inst (
        .clkout(clk_100M), // 100 MHz output
        .lock(pll_lock),   // PLL lock signal
        .clkin(clk)        // 50 MHz input
    );

    // Synchronize reset with PLL lock
    logic rst_n_sync;
    always_ff @(posedge clk_100M or negedge rst_n) begin
        if (!rst_n)
            rst_n_sync <= 0;
        else
            rst_n_sync <= pll_lock;
    end

    // Instantiate top_npu_system with 100 MHz clock
    top_npu_system npu_inst (
        .clk(clk_100M && pll_lock), // Use 100 MHz clock only when locked
        .rst_n(rst_n),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .miso(miso),
        .done(done)
    );
endmodule