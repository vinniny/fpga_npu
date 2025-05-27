library verilog;
use verilog.vl_types.all;
entity I3C_IOBUF is
    port(
        O               : out    vl_logic;
        IO              : inout  vl_logic;
        I               : in     vl_logic;
        MODESEL         : in     vl_logic
    );
end I3C_IOBUF;
