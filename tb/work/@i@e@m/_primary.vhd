library verilog;
use verilog.vl_types.all;
entity IEM is
    generic(
        WINSIZE         : string  := "SMALL";
        GSREN           : string  := "false";
        LSREN           : string  := "true"
    );
    port(
        LAG             : out    vl_logic;
        LEAD            : out    vl_logic;
        D               : in     vl_logic;
        CLK             : in     vl_logic;
        MCLK            : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WINSIZE : constant is 1;
    attribute mti_svvh_generic_type of GSREN : constant is 1;
    attribute mti_svvh_generic_type of LSREN : constant is 1;
end IEM;
