library verilog;
use verilog.vl_types.all;
entity IDDR is
    generic(
        Q0_INIT         : vl_logic := Hi0;
        Q1_INIT         : vl_logic := Hi0
    );
    port(
        Q0              : out    vl_logic;
        Q1              : out    vl_logic;
        D               : in     vl_logic;
        CLK             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Q0_INIT : constant is 1;
    attribute mti_svvh_generic_type of Q1_INIT : constant is 1;
end IDDR;
