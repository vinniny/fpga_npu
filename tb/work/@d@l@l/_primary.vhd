library verilog;
use verilog.vl_types.all;
entity DLL is
    generic(
        DLL_FORCE       : integer := 0;
        CODESCAL        : string  := "000";
        SCAL_EN         : string  := "true";
        DIV_SEL         : vl_logic := Hi0
    );
    port(
        STEP            : out    vl_logic_vector(7 downto 0);
        LOCK            : out    vl_logic;
        UPDNCNTL        : in     vl_logic;
        STOP            : in     vl_logic;
        CLKIN           : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DLL_FORCE : constant is 1;
    attribute mti_svvh_generic_type of CODESCAL : constant is 1;
    attribute mti_svvh_generic_type of SCAL_EN : constant is 1;
    attribute mti_svvh_generic_type of DIV_SEL : constant is 1;
end DLL;
