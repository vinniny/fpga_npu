library verilog;
use verilog.vl_types.all;
entity MUX16 is
    port(
        O               : out    vl_logic;
        I0              : in     vl_logic;
        I1              : in     vl_logic;
        I2              : in     vl_logic;
        I3              : in     vl_logic;
        I4              : in     vl_logic;
        I5              : in     vl_logic;
        I6              : in     vl_logic;
        I7              : in     vl_logic;
        I8              : in     vl_logic;
        I9              : in     vl_logic;
        I10             : in     vl_logic;
        I11             : in     vl_logic;
        I12             : in     vl_logic;
        I13             : in     vl_logic;
        I14             : in     vl_logic;
        I15             : in     vl_logic;
        S0              : in     vl_logic;
        S1              : in     vl_logic;
        S2              : in     vl_logic;
        S3              : in     vl_logic
    );
end MUX16;
