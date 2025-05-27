library verilog;
use verilog.vl_types.all;
entity ELVDS_IOBUF is
    port(
        O               : out    vl_logic;
        IO              : inout  vl_logic;
        IOB             : inout  vl_logic;
        I               : in     vl_logic;
        OEN             : in     vl_logic
    );
end ELVDS_IOBUF;
