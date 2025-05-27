library verilog;
use verilog.vl_types.all;
entity CLKDIVG is
    generic(
        DIV_MODE        : string  := "2";
        GSREN           : string  := "false"
    );
    port(
        CLKOUT          : out    vl_logic;
        CALIB           : in     vl_logic;
        CLKIN           : in     vl_logic;
        RESETN          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DIV_MODE : constant is 1;
    attribute mti_svvh_generic_type of GSREN : constant is 1;
end CLKDIVG;
