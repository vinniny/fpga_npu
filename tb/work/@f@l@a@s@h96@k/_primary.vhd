library verilog;
use verilog.vl_types.all;
entity FLASH96K is
    port(
        DOUT            : out    vl_logic_vector(31 downto 0);
        DIN             : in     vl_logic_vector(31 downto 0);
        RA              : in     vl_logic_vector(5 downto 0);
        CA              : in     vl_logic_vector(5 downto 0);
        PA              : in     vl_logic_vector(5 downto 0);
        SEQ             : in     vl_logic_vector(1 downto 0);
        MODE            : in     vl_logic_vector(3 downto 0);
        RMODE           : in     vl_logic_vector(1 downto 0);
        WMODE           : in     vl_logic_vector(1 downto 0);
        RBYTESEL        : in     vl_logic_vector(1 downto 0);
        WBYTESEL        : in     vl_logic_vector(1 downto 0);
        PW              : in     vl_logic;
        ACLK            : in     vl_logic;
        PE              : in     vl_logic;
        OE              : in     vl_logic;
        RESET           : in     vl_logic
    );
end FLASH96K;
