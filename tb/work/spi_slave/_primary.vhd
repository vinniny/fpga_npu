library verilog;
use verilog.vl_types.all;
entity spi_slave is
    port(
        sclk            : in     vl_logic;
        mosi            : in     vl_logic;
        cs_n            : in     vl_logic;
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        miso            : out    vl_logic;
        cmd             : out    vl_logic_vector(7 downto 0);
        tile_i          : out    vl_logic_vector(2 downto 0);
        tile_j          : out    vl_logic_vector(2 downto 0);
        op_code         : out    vl_logic_vector(2 downto 0);
        data_in         : out    vl_logic_vector(7 downto 0);
        data_out        : in     vl_logic_vector(7 downto 0);
        valid           : out    vl_logic
    );
end spi_slave;
