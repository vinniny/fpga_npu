module testbench;
    logic clk, rst_n, sclk, mosi, miso, cs_n, done;
    top_npu_system dut (.*);

    task send_spi(input [7:0] cmd, input [2:0] tile_i, tile_j, op_code, input [7:0] data);
        @(negedge sclk);
        cs_n = 0;
        for (int i = 23; i >= 0; i--) begin
            @(negedge sclk);
            mosi = (i >= 16) ? cmd[i-16] :
                   (i >= 13) ? tile_i[i-13] :
                   (i >= 10) ? tile_j[i-10] :
                   (i >= 7) ? op_code[i-7] : data[i];
        end
        @(posedge sclk);
        cs_n = 1;
    endtask

    task read_spi(input [7:0] cmd, input [2:0] tile_i, tile_j, op_code, output [7:0] result);
        logic [7:0] temp_result;
        @(negedge sclk);
        cs_n = 0;
        for (int i = 23; i >= 8; i--) begin
            @(negedge sclk);
            mosi = (i >= 16) ? cmd[i-16] :
                   (i >= 13) ? tile_i[i-13] :
                   (i >= 10) ? tile_j[i-10] :
                   (i >= 7) ? op_code[i-7] : 0;
        end
        for (int i = 7; i >= 0; i--) begin
            @(negedge sclk);
            mosi = 0;
            temp_result[i] = miso; // Shift bits into temp_result
        end
        @(posedge sclk);
        cs_n = 1;
        result = temp_result; // Assign final value to output
    endtask

    initial begin
        clk = 0; sclk = 0; rst_n = 0; cs_n = 1;
        #20 rst_n = 1;

        // Declare result variable for task output
        logic [7:0] result;

        // Test Multiplication
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                send_spi(8'h01, i, j, 0, 8'h01); // MUL, sample data
                send_spi(8'h01, i, j, 0, 8'h02);
            end
        end
        send_spi(8'h02, 0, 0, 0, 0); // START
        #10000; // Wait for computation
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                read_spi(8'h03, i, j, 0, result);
                $display("MUL Result[%0d,%0d]: %h", i, j, result);
            end
        end

        // Test Convolution
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                send_spi(8'h01, i, j, 3, 8'h01); // CONV
                send_spi(8'h01, i, j, 3, 8'h02);
            end
        end
        send_spi(8'h02, 0, 0, 3, 0);
        #10000;
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                read_spi(8'h03, i, j, 3, result);
                $display("CONV Result[%0d,%0d]: %h", i, j, result);
            end
        end

        $finish;
    end

    always #18.518 clk = ~clk; // 27 MHz
    always #25 sclk = ~sclk; // 20 MHz
endmodule