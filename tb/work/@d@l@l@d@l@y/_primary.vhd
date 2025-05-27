library verilog;
use verilog.vl_types.all;
entity DLLDLY is
    generic(
        DLL_INSEL       : vl_logic := Hi0;
        DLY_SIGN        : vl_logic := Hi0;
        DLY_ADJ         : integer := 0
    );
    port(
        CLKOUT          : out    vl_logic;
        FLAG            : out    vl_logic;
        DLLSTEP         : in     vl_logic_vector(7 downto 0);
        LOADN           : in     vl_logic;
        MOVE            : in     vl_logic;
        DIR             : in     vl_logic;
        CLKIN           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DLL_INSEL : constant is 1;
    attribute mti_svvh_generic_type of DLY_SIGN : constant is 1;
    attribute mti_svvh_generic_type of DLY_ADJ : constant is 1;
end DLLDLY;
