library verilog;
use verilog.vl_types.all;
entity top is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sclk            : in     vl_logic;
        mosi            : in     vl_logic;
        cs_n            : in     vl_logic;
        miso            : out    vl_logic;
        done            : out    vl_logic
    );
end top;
