library verilog;
use verilog.vl_types.all;
entity ALU is
    generic(
        ADD             : integer := 0;
        SUB             : integer := 1;
        ADDSUB          : integer := 2;
        NE              : integer := 3;
        GE              : integer := 4;
        LE              : integer := 5;
        CUP             : integer := 6;
        CDN             : integer := 7;
        CUPCDN          : integer := 8;
        MULT            : integer := 9;
        ALU_MODE        : integer := 0
    );
    port(
        SUM             : out    vl_logic;
        COUT            : out    vl_logic;
        I0              : in     vl_logic;
        I1              : in     vl_logic;
        I3              : in     vl_logic;
        CIN             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADD : constant is 1;
    attribute mti_svvh_generic_type of SUB : constant is 1;
    attribute mti_svvh_generic_type of ADDSUB : constant is 1;
    attribute mti_svvh_generic_type of NE : constant is 1;
    attribute mti_svvh_generic_type of GE : constant is 1;
    attribute mti_svvh_generic_type of LE : constant is 1;
    attribute mti_svvh_generic_type of CUP : constant is 1;
    attribute mti_svvh_generic_type of CDN : constant is 1;
    attribute mti_svvh_generic_type of CUPCDN : constant is 1;
    attribute mti_svvh_generic_type of MULT : constant is 1;
    attribute mti_svvh_generic_type of ALU_MODE : constant is 1;
end ALU;
