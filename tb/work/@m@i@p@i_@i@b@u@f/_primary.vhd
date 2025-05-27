library verilog;
use verilog.vl_types.all;
entity MIPI_IBUF is
    port(
        OH              : out    vl_logic;
        OL              : out    vl_logic;
        OB              : out    vl_logic;
        IO              : inout  vl_logic;
        IOB             : inout  vl_logic;
        I               : in     vl_logic;
        IB              : in     vl_logic;
        OEN             : in     vl_logic;
        OENB            : in     vl_logic;
        HSREN           : in     vl_logic
    );
end MIPI_IBUF;
