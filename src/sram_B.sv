module sram_B (
    input  logic        clk,
    input  logic        ce,
    input  logic        we,
    input  logic [9:0]  addr,
    input  logic [7:0]  din,
    output logic [7:0]  dout
);
    logic [7:0] mem [0:1023];

    initial begin
        $readmemh("sram_B_init.hex", mem);
    end

    always_ff @(posedge clk) begin
        if (ce) begin
            if (we)
                mem[addr] <= din;
            dout <= mem[addr];
        end
    end
endmodule
