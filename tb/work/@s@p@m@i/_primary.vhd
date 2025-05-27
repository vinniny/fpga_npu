library verilog;
use verilog.vl_types.all;
entity SPMI is
    generic(
        FUNCTION_CTRL   : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        MSID_CLKSEL     : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        RESPOND_DELAY   : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        SCLK_NORMAL_PERIOD: vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        SCLK_LOW_PERIOD : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        CLK_FREQ        : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        SHUTDOWN_BY_ENABLE: vl_logic := Hi0
    );
    port(
        CLK             : in     vl_logic;
        CLKEXT          : in     vl_logic;
        CE              : in     vl_logic;
        RESETN          : in     vl_logic;
        ENEXT           : in     vl_logic;
        LOCRESET        : in     vl_logic;
        PA              : in     vl_logic;
        SA              : in     vl_logic;
        CA              : in     vl_logic;
        ADDRI           : in     vl_logic_vector(3 downto 0);
        DATAI           : in     vl_logic_vector(7 downto 0);
        ADDRO           : out    vl_logic_vector(3 downto 0);
        DATAO           : out    vl_logic_vector(7 downto 0);
        STATE           : out    vl_logic_vector(15 downto 0);
        CMD             : out    vl_logic_vector(3 downto 0);
        SDATA           : inout  vl_logic;
        SCLK            : inout  vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FUNCTION_CTRL : constant is 1;
    attribute mti_svvh_generic_type of MSID_CLKSEL : constant is 1;
    attribute mti_svvh_generic_type of RESPOND_DELAY : constant is 1;
    attribute mti_svvh_generic_type of SCLK_NORMAL_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of SCLK_LOW_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of CLK_FREQ : constant is 1;
    attribute mti_svvh_generic_type of SHUTDOWN_BY_ENABLE : constant is 1;
end SPMI;
