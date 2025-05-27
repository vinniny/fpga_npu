library verilog;
use verilog.vl_types.all;
entity matrix_subtraction is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        a               : in     vl_logic;
        b               : in     vl_logic;
        c               : out    vl_logic;
        done            : out    vl_logic
    );
end matrix_subtraction;
