library verilog;
use verilog.vl_types.all;
entity DCC is
    generic(
        DCC_EN          : vl_logic := Hi1;
        FCLKIN          : real    := 50.000000
    );
    port(
        CLKOUT          : out    vl_logic;
        CLKIN           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DCC_EN : constant is 1;
    attribute mti_svvh_generic_type of FCLKIN : constant is 1;
end DCC;
