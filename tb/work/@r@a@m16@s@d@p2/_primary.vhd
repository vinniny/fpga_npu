library verilog;
use verilog.vl_types.all;
entity RAM16SDP2 is
    generic(
        INIT_0          : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        INIT_1          : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        DO              : out    vl_logic_vector(1 downto 0);
        DI              : in     vl_logic_vector(1 downto 0);
        WAD             : in     vl_logic_vector(3 downto 0);
        RAD             : in     vl_logic_vector(3 downto 0);
        WRE             : in     vl_logic;
        CLK             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INIT_0 : constant is 1;
    attribute mti_svvh_generic_type of INIT_1 : constant is 1;
end RAM16SDP2;
