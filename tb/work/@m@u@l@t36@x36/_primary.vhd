library verilog;
use verilog.vl_types.all;
entity MULT36X36 is
    generic(
        AREG            : vl_logic := Hi0;
        BREG            : vl_logic := Hi0;
        OUT0_REG        : vl_logic := Hi0;
        OUT1_REG        : vl_logic := Hi0;
        PIPE_REG        : vl_logic := Hi0;
        ASIGN_REG       : vl_logic := Hi0;
        BSIGN_REG       : vl_logic := Hi0;
        MULT_RESET_MODE : string  := "SYNC"
    );
    port(
        DOUT            : out    vl_logic_vector(71 downto 0);
        A               : in     vl_logic_vector(35 downto 0);
        B               : in     vl_logic_vector(35 downto 0);
        ASIGN           : in     vl_logic;
        BSIGN           : in     vl_logic;
        CLK             : in     vl_logic;
        CE              : in     vl_logic;
        RESET           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AREG : constant is 1;
    attribute mti_svvh_generic_type of BREG : constant is 1;
    attribute mti_svvh_generic_type of OUT0_REG : constant is 1;
    attribute mti_svvh_generic_type of OUT1_REG : constant is 1;
    attribute mti_svvh_generic_type of PIPE_REG : constant is 1;
    attribute mti_svvh_generic_type of ASIGN_REG : constant is 1;
    attribute mti_svvh_generic_type of BSIGN_REG : constant is 1;
    attribute mti_svvh_generic_type of MULT_RESET_MODE : constant is 1;
end MULT36X36;
