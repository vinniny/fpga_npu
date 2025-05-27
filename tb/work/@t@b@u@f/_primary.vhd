library verilog;
use verilog.vl_types.all;
entity TBUF is
    port(
        O               : out    vl_logic;
        I               : in     vl_logic;
        OEN             : in     vl_logic
    );
end TBUF;
