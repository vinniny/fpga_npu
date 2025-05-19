module matrix_dot (
    input clk, rst_n, start,
    input [7:0] a [0:31],
    input [7:0] b [0:31],
    output logic [15:0] c,
    output logic done
);
    logic [5:0] i;
    logic computing;
    logic [17:0] dsp_a0, dsp_b0;
    logic [36:0] dsp_out;

    Gowin_MULTADDALU dsp_inst (
        .a0(dsp_a0),
        .b0(dsp_b0),
        .a1(18'd0),
        .b1(18'd0),
        .dout(dsp_out),
        .caso(),
        .ce(computing),
        .clk(clk),
        .reset(~rst_n)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i <= 0; c <= 0; done <= 0; computing <= 0;
            dsp_a0 <= 0; dsp_b0 <= 0;
        end else if (start && !computing) begin
            computing <= 1;
        end else if (computing) begin
            dsp_a0 <= {10'd0, a[i]};
            dsp_b0 <= {10'd0, b[i]};
            c <= dsp_out[15:0];
            if (i < 6'd32) begin // Changed to 6-bit literal
                i <= i + 1;
            end else begin
                done <= 1; computing <= 0;
            end
        end
    end
endmodule