library verilog;
use verilog.vl_types.all;
entity OSC is
    generic(
        FREQ_DIV        : integer := 100;
        DEVICE          : string  := "GW1N-4"
    );
    port(
        OSCOUT          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FREQ_DIV : constant is 1;
    attribute mti_svvh_generic_type of DEVICE : constant is 1;
end OSC;
