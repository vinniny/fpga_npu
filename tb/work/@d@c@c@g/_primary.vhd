library verilog;
use verilog.vl_types.all;
entity DCCG is
    generic(
        DCC_MODE        : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        FCLKIN          : real    := 50.000000
    );
    port(
        CLKOUT          : out    vl_logic;
        CLKIN           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DCC_MODE : constant is 1;
    attribute mti_svvh_generic_type of FCLKIN : constant is 1;
end DCCG;
