library verilog;
use verilog.vl_types.all;
entity MUX2 is
    port(
        O               : out    vl_logic;
        I0              : in     vl_logic;
        I1              : in     vl_logic;
        S0              : in     vl_logic
    );
end MUX2;
