library verilog;
use verilog.vl_types.all;
entity TLVDS_OBUF is
    port(
        O               : out    vl_logic;
        OB              : out    vl_logic;
        I               : in     vl_logic
    );
end TLVDS_OBUF;
