library verilog;
use verilog.vl_types.all;
entity MIPI_IBUF_HS is
    port(
        OH              : out    vl_logic;
        I               : in     vl_logic;
        IB              : in     vl_logic
    );
end MIPI_IBUF_HS;
