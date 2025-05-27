library verilog;
use verilog.vl_types.all;
entity DFFPE is
    generic(
        INIT            : vl_logic := Hi1
    );
    port(
        Q               : out    vl_logic;
        D               : in     vl_logic;
        CLK             : in     vl_logic;
        CE              : in     vl_logic;
        PRESET          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INIT : constant is 1;
end DFFPE;
