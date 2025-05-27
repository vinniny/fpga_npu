library verilog;
use verilog.vl_types.all;
entity MULTALU36X18 is
    generic(
        AREG            : vl_logic := Hi0;
        BREG            : vl_logic := Hi0;
        CREG            : vl_logic := Hi0;
        OUT_REG         : vl_logic := Hi0;
        PIPE_REG        : vl_logic := Hi0;
        ASIGN_REG       : vl_logic := Hi0;
        BSIGN_REG       : vl_logic := Hi0;
        ACCLOAD_REG0    : vl_logic := Hi0;
        ACCLOAD_REG1    : vl_logic := Hi0;
        MULT_RESET_MODE : string  := "SYNC";
        MULTALU36X18_MODE: integer := 0;
        C_ADD_SUB       : vl_logic := Hi0
    );
    port(
        DOUT            : out    vl_logic_vector(53 downto 0);
        CASO            : out    vl_logic_vector(54 downto 0);
        A               : in     vl_logic_vector(17 downto 0);
        B               : in     vl_logic_vector(35 downto 0);
        C               : in     vl_logic_vector(53 downto 0);
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
    attribute mti_svvh_generic_type of CREG : constant is 1;
    attribute mti_svvh_generic_type of OUT_REG : constant is 1;
    attribute mti_svvh_generic_type of PIPE_REG : constant is 1;
    attribute mti_svvh_generic_type of ASIGN_REG : constant is 1;
    attribute mti_svvh_generic_type of BSIGN_REG : constant is 1;
    attribute mti_svvh_generic_type of ACCLOAD_REG0 : constant is 1;
    attribute mti_svvh_generic_type of ACCLOAD_REG1 : constant is 1;
    attribute mti_svvh_generic_type of MULT_RESET_MODE : constant is 1;
    attribute mti_svvh_generic_type of MULTALU36X18_MODE : constant is 1;
    attribute mti_svvh_generic_type of C_ADD_SUB : constant is 1;
end MULTALU36X18;
