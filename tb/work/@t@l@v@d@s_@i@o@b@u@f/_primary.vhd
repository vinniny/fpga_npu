library verilog;
use verilog.vl_types.all;
entity TLVDS_IOBUF is
    port(
        O               : out    vl_logic;
        IO              : inout  vl_logic;
        IOB             : inout  vl_logic;
        I               : in     vl_logic;
        OEN             : in     vl_logic
    );
end TLVDS_IOBUF;
