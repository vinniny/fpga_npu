library verilog;
use verilog.vl_types.all;
entity ODDR is
    generic(
        TXCLK_POL       : vl_logic := Hi0;
        INIT            : vl_logic := Hi0
    );
    port(
        Q0              : out    vl_logic;
        Q1              : out    vl_logic;
        D0              : in     vl_logic;
        D1              : in     vl_logic;
        TX              : in     vl_logic;
        CLK             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TXCLK_POL : constant is 1;
    attribute mti_svvh_generic_type of INIT : constant is 1;
end ODDR;
