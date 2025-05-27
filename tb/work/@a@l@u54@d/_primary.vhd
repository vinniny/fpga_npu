library verilog;
use verilog.vl_types.all;
entity ALU54D is
    generic(
        AREG            : vl_logic := Hi0;
        BREG            : vl_logic := Hi0;
        ASIGN_REG       : vl_logic := Hi0;
        BSIGN_REG       : vl_logic := Hi0;
        ACCLOAD_REG     : vl_logic := Hi0;
        OUT_REG         : vl_logic := Hi0;
        B_ADD_SUB       : vl_logic := Hi0;
        C_ADD_SUB       : vl_logic := Hi0;
        ALUD_MODE       : integer := 0;
        ALU_RESET_MODE  : string  := "SYNC"
    );
    port(
        DOUT            : out    vl_logic_vector(53 downto 0);
        CASO            : out    vl_logic_vector(54 downto 0);
        A               : in     vl_logic_vector(53 downto 0);
        B               : in     vl_logic_vector(53 downto 0);
        CASI            : in     vl_logic_vector(54 downto 0);
        ACCLOAD         : in     vl_logic;
        ASIGN           : in     vl_logic;
        BSIGN           : in     vl_logic;
        CLK             : in     vl_logic;
        CE              : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AREG : constant is 1;
    attribute mti_svvh_generic_type of BREG : constant is 1;
    attribute mti_svvh_generic_type of ASIGN_REG : constant is 1;
    attribute mti_svvh_generic_type of BSIGN_REG : constant is 1;
    attribute mti_svvh_generic_type of ACCLOAD_REG : constant is 1;
    attribute mti_svvh_generic_type of OUT_REG : constant is 1;
    attribute mti_svvh_generic_type of B_ADD_SUB : constant is 1;
    attribute mti_svvh_generic_type of C_ADD_SUB : constant is 1;
    attribute mti_svvh_generic_type of ALUD_MODE : constant is 1;
    attribute mti_svvh_generic_type of ALU_RESET_MODE : constant is 1;
end ALU54D;
