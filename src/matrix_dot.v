(* use_dsp = "no" *)
module matrix_dot (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:15],
    input logic [7:0] b [0:15],
    output logic [15:0] c,
    output logic done
);
logic [4:0] i;
logic computing;
logic [15:0] temp;
logic [7:0] mul_counter;
logic [15:0] mul_result;
logic [127:0] a_flat;
logic [7:0] index; // Temporary register for index

always_comb begin
    for (int j = 0; j < 16; j++) begin
        a_flat[8*j +: 8] = a[j];
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        i <= 0; c <= 0; done <= 0; computing <= 0; temp <= 0; mul_counter <= 0; mul_result <= 0; index <= 0;
    end else if (start && !computing) begin
        computing <= 1;
        i <= 0; c <= 0; mul_counter <= 0; mul_result <= 0; index <= 0;
    end else if (computing) begin
        index <= i << 3; // Compute 8*i (shift left by 3 is equivalent to *8)
        if (mul_counter == 0) begin
            mul_result <= 0;
            mul_counter <= a_flat[index +: 8]; // Use precomputed index
        end else if (mul_counter > 0) begin
            mul_result <= mul_result + b[i];
            mul_counter <= mul_counter - 1;
        end

        if (mul_counter == 0) begin
            temp <= mul_result;
            c <= c + temp;
            if (i < 15) begin
                i <= 5'(i + 1);
                mul_counter <= 0;
            end else begin
                done <= 1;
                computing <= 0;
            end
        end
    end
end
endmodule