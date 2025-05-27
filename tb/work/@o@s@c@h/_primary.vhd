library verilog;
use verilog.vl_types.all;
entity OSCH is
    generic(
        FREQ_DIV        : integer := 96
    );
    port(
        OSCOUT          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FREQ_DIV : constant is 1;
end OSCH;
