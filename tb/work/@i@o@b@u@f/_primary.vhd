library verilog;
use verilog.vl_types.all;
entity IOBUF is
    port(
        O               : out    vl_logic;
        IO              : inout  vl_logic;
        I               : in     vl_logic;
        OEN             : in     vl_logic
    );
end IOBUF;
