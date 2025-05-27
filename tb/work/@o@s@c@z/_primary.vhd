library verilog;
use verilog.vl_types.all;
entity OSCZ is
    generic(
        FREQ_DIV        : integer := 100;
        S_RATE          : string  := "SLOW"
    );
    port(
        OSCOUT          : out    vl_logic;
        OSCEN           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FREQ_DIV : constant is 1;
    attribute mti_svvh_generic_type of S_RATE : constant is 1;
end OSCZ;
