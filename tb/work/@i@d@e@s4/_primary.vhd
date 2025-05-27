library verilog;
use verilog.vl_types.all;
entity IDES4 is
    generic(
        GSREN           : string  := "false";
        LSREN           : string  := "true"
    );
    port(
        Q0              : out    vl_logic;
        Q1              : out    vl_logic;
        Q2              : out    vl_logic;
        Q3              : out    vl_logic;
        D               : in     vl_logic;
        CALIB           : in     vl_logic;
        PCLK            : in     vl_logic;
        FCLK            : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GSREN : constant is 1;
    attribute mti_svvh_generic_type of LSREN : constant is 1;
end IDES4;
