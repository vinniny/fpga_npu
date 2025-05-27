library verilog;
use verilog.vl_types.all;
entity CLKDIV2 is
    generic(
        GSREN           : string  := "false"
    );
    port(
        CLKOUT          : out    vl_logic;
        HCLKIN          : in     vl_logic;
        RESETN          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GSREN : constant is 1;
end CLKDIV2;
