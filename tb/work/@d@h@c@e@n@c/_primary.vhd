library verilog;
use verilog.vl_types.all;
entity DHCENC is
    port(
        CLKOUT          : out    vl_logic;
        CLKOUTN         : out    vl_logic;
        CLKIN           : in     vl_logic;
        CE              : in     vl_logic
    );
end DHCENC;
