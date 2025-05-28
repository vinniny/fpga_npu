(* use_dsp = "no" *)
module matrix_dot (
    input logic clk, rst_n, start,
    input logic [127:0] a, // Packed 128-bit (16 x 8-bit)
    input logic [127:0] b, // Packed 128-bit (16 x 8-bit)
    output logic [31:0] c, // 32-bit output to avoid truncation
    output logic done
);
    logic [4:0] i;
    logic computing;
    logic [31:0] sum; // 32-bit to prevent overflow
    logic [7:0] a_slice, b_slice;

    // Extract 8-bit slices
    always_comb begin
        a_slice = a[i*8 +: 8];
        b_slice = b[i*8 +: 8];
    end

    // FSM and computation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            c <= 0;
            done <= 0;
            computing <= 0;
            sum <= 0;
        end else if (start && !computing) begin
            computing <= 1;
            i <= 0;
            c <= 0;
            sum <= 0;
            done <= 0;
        end else if (computing) begin
            sum <= sum + (a_slice * b_slice); // Unsigned multiplication
            if (i < 15) begin
                i <= i + 1;
            end else begin
                c <= sum + (a_slice * b_slice); // Final sum
                done <= 1;
                computing <= 0;
            end
        end
    end
endmodule