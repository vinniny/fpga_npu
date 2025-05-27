module sram_A (
    input  logic        clk,
    input  logic        ce,
(* syn_keep = 1 *)     input  logic        we,
(* syn_keep = 1 *)     input  logic [9:0]  addr,
    input  logic [7:0]  din,
(* syn_keep = 1 *)     output logic [7:0]  dout
);
    logic [7:0] mem [0:1023];

    initial begin
        $readmemh("sram_A_init.hex", mem);
    end

    always_ff @(posedge clk) begin
        if (ce) begin
            if (we)
                mem[addr] <= din;
            dout <= mem[addr];
        end
    end
endmodule
