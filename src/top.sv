module top (
    input logic clk, rst_n, sclk, mosi, cs_n,
    output logic miso, done
);
    logic rpll_clk /* synthesis syn_keep=1 */; // 47.25 MHz clock
    logic pll_lock; // PLL lock signal
    logic rpll_clk_reg /* synthesis syn_keep=1 */; // Dummy register

    // Instantiate rPLL for 27 MHz to 47.25 MHz
    Gowin_rPLL pll_inst (
        .clkout(rpll_clk),
        .lock(pll_lock),
        .clkin(clk)
    );

    // Dummy register to preserve rpll_clk
    always_ff @(posedge rpll_clk or negedge rst_n) begin
        if (!rst_n)
            rpll_clk_reg <= 0;
        else
            rpll_clk_reg <= 1;
    end

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