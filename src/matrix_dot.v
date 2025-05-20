(* DSP_STYLE = "logic" *)
module matrix_dot (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:15],
    input logic [7:0] b [0:15],
    output logic [15:0] c,
    output logic done
);
    logic [3:0] i;
    logic computing;
    (* use_dsp = "no" *) logic [15:0] temp;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i <= 0; c <= 0; done <= 0; computing <= 0; temp <= 0;
        end else if (start && !computing) begin
            computing <= 1;
            i <= 0; c <= 0;
        end else if (computing) begin
            (* use_dsp = "no" *) temp = a[i] * b[i]; // LUT-based multiplication
            (* use_dsp = "no" *) c <= c + temp;      // LUT-based accumulation
            if (i < 15) begin
                i <= i + 1;
            end else begin
                done <= 1;
                computing <= 0;
            end
        end
    end
endmodule