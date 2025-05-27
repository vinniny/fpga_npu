library verilog;
use verilog.vl_types.all;
entity IODELAYA is
    generic(
        C_STATIC_DLY    : integer := 0
    );
    port(
        DO              : out    vl_logic;
        DF              : out    vl_logic;
        DI              : in     vl_logic;
        SDTAP           : in     vl_logic;
        VALUE           : in     vl_logic;
        SETN            : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_STATIC_DLY : constant is 1;
end IODELAYA;
