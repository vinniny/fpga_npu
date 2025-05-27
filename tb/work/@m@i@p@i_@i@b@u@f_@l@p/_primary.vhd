library verilog;
use verilog.vl_types.all;
entity MIPI_IBUF_LP is
    port(
        OL              : out    vl_logic;
        OB              : out    vl_logic;
        I               : in     vl_logic;
        IB              : in     vl_logic
    );
end MIPI_IBUF_LP;
