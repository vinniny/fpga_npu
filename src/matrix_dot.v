module matrix_dot (
    input logic clk, rst_n, start,
    input logic [7:0] a [0:31],
    input logic [7:0] b [0:31],
    output logic [15:0] c,
    output logic [17:0] dsp_a0 [0:15], dsp_b0 [0:15],
    input logic [36:0] dsp_out [0:15],
    output logic dsp_ce,
    output logic done
);
    logic [7:0] i; // Widened to 8 bits
    logic iter;
    logic computing;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i <= 0; iter <= 0; c <= 0; done <= 0; computing <= 0; dsp_ce <= 0;
            for (int z = 0; z < 16; z++) begin
                dsp_a0[z] <= 0;
                dsp_b0[z] <= 0;
            end
        end else if (start && !computing) begin
            computing <= 1;
            i <= 0; iter <= 0;
            dsp_ce <= 1;
        end else if (computing) begin
            if (iter == 0) begin
                for (int z = 0; z < 16; z++) begin
                    dsp_a0[z] <= {10'd0, a[i+z]}; dsp_b0[z] <= {10'd0, b[i+z]};
                end
                for (int z = 0; z < 16; z++)
                    c <= c + dsp_out[z][15:0];
            end else begin
                for (int z = 0; z < 16; z++) begin
                    dsp_a0[z] <= {10'd0, a[i+z]}; dsp_b0[z] <= {10'd0, b[i+z]};
                end
                for (int z = 0; z < 16; z++)
                    c <= c + dsp_out[z][15:0];
            end
            if (iter == 0) begin
                i <= i + 16; iter <= 1;
            end else begin
                done <= 1; computing <= 0; dsp_ce <= 0;
            end
        end
    end
endmodule