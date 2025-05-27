library verilog;
use verilog.vl_types.all;
entity IODELAYB is
    generic(
        C_STATIC_DLY    : integer := 0;
        DELAY_MUX       : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        DA_SEL          : vl_logic_vector(0 to 1) := (Hi0, Hi0)
    );
    port(
        DO              : out    vl_logic;
        DAO             : out    vl_logic;
        DF              : out    vl_logic;
        DI              : in     vl_logic;
        SDTAP           : in     vl_logic;
        VALUE           : in     vl_logic;
        SETN            : in     vl_logic;
        DAADJ           : in     vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_STATIC_DLY : constant is 1;
    attribute mti_svvh_generic_type of DELAY_MUX : constant is 1;
    attribute mti_svvh_generic_type of DA_SEL : constant is 1;
end IODELAYB;
