library verilog;
use verilog.vl_types.all;
entity OSCO is
    generic(
        FREQ_DIV        : integer := 100;
        REGULATOR_EN    : vl_logic := Hi0
    );
    port(
        OSCOUT          : out    vl_logic;
        OSCEN           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FREQ_DIV : constant is 1;
    attribute mti_svvh_generic_type of REGULATOR_EN : constant is 1;
end OSCO;
