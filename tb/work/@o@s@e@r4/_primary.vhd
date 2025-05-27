library verilog;
use verilog.vl_types.all;
entity OSER4 is
    generic(
        GSREN           : string  := "false";
        LSREN           : string  := "true";
        HWL             : string  := "false";
        TXCLK_POL       : vl_logic := Hi0
    );
    port(
        Q0              : out    vl_logic;
        Q1              : out    vl_logic;
        D0              : in     vl_logic;
        D1              : in     vl_logic;
        D2              : in     vl_logic;
        D3              : in     vl_logic;
        TX0             : in     vl_logic;
        TX1             : in     vl_logic;
        PCLK            : in     vl_logic;
        FCLK            : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GSREN : constant is 1;
    attribute mti_svvh_generic_type of LSREN : constant is 1;
    attribute mti_svvh_generic_type of HWL : constant is 1;
    attribute mti_svvh_generic_type of TXCLK_POL : constant is 1;
end OSER4;
