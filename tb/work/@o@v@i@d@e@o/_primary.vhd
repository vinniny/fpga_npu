library verilog;
use verilog.vl_types.all;
entity OVIDEO is
    generic(
        GSREN           : string  := "false";
        LSREN           : string  := "true"
    );
    port(
        Q               : out    vl_logic;
        D0              : in     vl_logic;
        D1              : in     vl_logic;
        D2              : in     vl_logic;
        D3              : in     vl_logic;
        D4              : in     vl_logic;
        D5              : in     vl_logic;
        D6              : in     vl_logic;
        PCLK            : in     vl_logic;
        FCLK            : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GSREN : constant is 1;
    attribute mti_svvh_generic_type of LSREN : constant is 1;
end OVIDEO;
