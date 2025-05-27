library verilog;
use verilog.vl_types.all;
entity MIPI_OBUF_A is
    port(
        O               : out    vl_logic;
        OB              : out    vl_logic;
        I               : in     vl_logic;
        IB              : in     vl_logic;
        IL              : in     vl_logic;
        MODESEL         : in     vl_logic
    );
end MIPI_OBUF_A;
