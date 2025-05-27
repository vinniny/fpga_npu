library verilog;
use verilog.vl_types.all;
entity Gowin_MULTADDALU is
    port(
        dout            : out    vl_logic_vector(36 downto 0);
        caso            : out    vl_logic_vector(54 downto 0);
        a0              : in     vl_logic_vector(17 downto 0);
        b0              : in     vl_logic_vector(17 downto 0);
        a1              : in     vl_logic_vector(17 downto 0);
        b1              : in     vl_logic_vector(17 downto 0);
        ce              : in     vl_logic;
        clk             : in     vl_logic;
        reset           : in     vl_logic
    );
end Gowin_MULTADDALU;
