library verilog;
use verilog.vl_types.all;
entity matrix_dot is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        a               : in     vl_logic_vector(127 downto 0);
        b               : in     vl_logic_vector(127 downto 0);
        c               : out    vl_logic_vector(31 downto 0);
        done            : out    vl_logic
    );
end matrix_dot;
