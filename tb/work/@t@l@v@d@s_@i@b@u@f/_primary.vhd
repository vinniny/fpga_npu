library verilog;
use verilog.vl_types.all;
entity TLVDS_IBUF is
    port(
        O               : out    vl_logic;
        I               : in     vl_logic;
        IB              : in     vl_logic
    );
end TLVDS_IBUF;
