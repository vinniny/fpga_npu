library verilog;
use verilog.vl_types.all;
entity DCS is
    generic(
        DCS_MODE        : string  := "RISING"
    );
    port(
        CLKOUT          : out    vl_logic;
        CLK0            : in     vl_logic;
        CLK1            : in     vl_logic;
        CLK2            : in     vl_logic;
        CLK3            : in     vl_logic;
        CLKSEL          : in     vl_logic_vector(3 downto 0);
        SELFORCE        : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DCS_MODE : constant is 1;
end DCS;
