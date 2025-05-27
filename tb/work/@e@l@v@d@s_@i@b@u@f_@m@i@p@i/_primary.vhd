library verilog;
use verilog.vl_types.all;
entity ELVDS_IBUF_MIPI is
    port(
        OH              : out    vl_logic;
        OL              : out    vl_logic;
        I               : in     vl_logic;
        IB              : in     vl_logic
    );
end ELVDS_IBUF_MIPI;
