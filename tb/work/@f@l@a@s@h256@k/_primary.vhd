library verilog;
use verilog.vl_types.all;
entity FLASH256K is
    generic(
        IDLE            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        ERA_S1          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        ERA_S2          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        ERA_S3          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        ERA_S4          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        ERA_S5          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        PRO_S1          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        PRO_S2          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        PRO_S3          : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        PRO_S4          : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1);
        PRO_S5          : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi0);
        RD_S1           : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi1);
        RD_S2           : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi0, Hi0)
    );
    port(
        DOUT            : out    vl_logic_vector(31 downto 0);
        DIN             : in     vl_logic_vector(31 downto 0);
        XADR            : in     vl_logic_vector(6 downto 0);
        YADR            : in     vl_logic_vector(5 downto 0);
        XE              : in     vl_logic;
        YE              : in     vl_logic;
        SE              : in     vl_logic;
        ERASE           : in     vl_logic;
        PROG            : in     vl_logic;
        NVSTR           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of ERA_S1 : constant is 1;
    attribute mti_svvh_generic_type of ERA_S2 : constant is 1;
    attribute mti_svvh_generic_type of ERA_S3 : constant is 1;
    attribute mti_svvh_generic_type of ERA_S4 : constant is 1;
    attribute mti_svvh_generic_type of ERA_S5 : constant is 1;
    attribute mti_svvh_generic_type of PRO_S1 : constant is 1;
    attribute mti_svvh_generic_type of PRO_S2 : constant is 1;
    attribute mti_svvh_generic_type of PRO_S3 : constant is 1;
    attribute mti_svvh_generic_type of PRO_S4 : constant is 1;
    attribute mti_svvh_generic_type of PRO_S5 : constant is 1;
    attribute mti_svvh_generic_type of RD_S1 : constant is 1;
    attribute mti_svvh_generic_type of RD_S2 : constant is 1;
end FLASH256K;
