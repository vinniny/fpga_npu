library verilog;
use verilog.vl_types.all;
entity Gowin_rPLL is
    port(
        clkout          : out    vl_logic;
        lock            : out    vl_logic;
        clkin           : in     vl_logic
    );
end Gowin_rPLL;
