library verilog;
use verilog.vl_types.all;
entity tile_processor is
    generic(
        MUL             : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        ADD             : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        SUB             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        CONV            : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        DOT             : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        tile_i          : in     vl_logic_vector(2 downto 0);
        tile_j          : in     vl_logic_vector(2 downto 0);
        op_code         : in     vl_logic_vector(2 downto 0);
        sram_A_dout     : in     vl_logic_vector(7 downto 0);
        sram_B_dout     : in     vl_logic_vector(7 downto 0);
        tp_sram_A_we    : out    vl_logic;
        tp_sram_B_we    : out    vl_logic;
        tp_sram_C_we    : out    vl_logic;
        tp_sram_A_ce    : out    vl_logic;
        tp_sram_B_ce    : out    vl_logic;
        tp_sram_C_ce    : out    vl_logic;
        tp_sram_A_addr  : out    vl_logic_vector(9 downto 0);
        tp_sram_B_addr  : out    vl_logic_vector(9 downto 0);
        tp_sram_C_addr  : out    vl_logic_vector(9 downto 0);
        tp_sram_A_din   : out    vl_logic_vector(7 downto 0);
        tp_sram_B_din   : out    vl_logic_vector(7 downto 0);
        tp_sram_C_din   : out    vl_logic_vector(7 downto 0);
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MUL : constant is 1;
    attribute mti_svvh_generic_type of ADD : constant is 1;
    attribute mti_svvh_generic_type of SUB : constant is 1;
    attribute mti_svvh_generic_type of CONV : constant is 1;
    attribute mti_svvh_generic_type of DOT : constant is 1;
end tile_processor;
