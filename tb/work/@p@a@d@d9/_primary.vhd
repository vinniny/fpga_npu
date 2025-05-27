library verilog;
use verilog.vl_types.all;
entity PADD9 is
    generic(
        AREG            : vl_logic := Hi0;
        BREG            : vl_logic := Hi0;
        ADD_SUB         : vl_logic := Hi0;
        PADD_RESET_MODE : string  := "SYNC";
        BSEL_MODE       : vl_logic := Hi1;
        SOREG           : vl_logic := Hi0
    );
    port(
        DOUT            : out    vl_logic_vector(8 downto 0);
        SO              : out    vl_logic_vector(8 downto 0);
        SBO             : out    vl_logic_vector(8 downto 0);
        A               : in     vl_logic_vector(8 downto 0);
        B               : in     vl_logic_vector(8 downto 0);
        SI              : in     vl_logic_vector(8 downto 0);
        SBI             : in     vl_logic_vector(8 downto 0);
        ASEL            : in     vl_logic;
        CLK             : in     vl_logic;
        CE              : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AREG : constant is 1;
    attribute mti_svvh_generic_type of BREG : constant is 1;
    attribute mti_svvh_generic_type of ADD_SUB : constant is 1;
    attribute mti_svvh_generic_type of PADD_RESET_MODE : constant is 1;
    attribute mti_svvh_generic_type of BSEL_MODE : constant is 1;
    attribute mti_svvh_generic_type of SOREG : constant is 1;
end PADD9;
