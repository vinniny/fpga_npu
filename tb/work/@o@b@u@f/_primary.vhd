library verilog;
use verilog.vl_types.all;
entity OBUF is
    port(
        O               : out    vl_logic;
        I               : in     vl_logic
    );
end OBUF;
