`include "../common/npu_definitions.vh"

module activation_unit (
    input wire clk,
    input wire rst_n,
    input wire [39:0] data_in,
    input wire valid,
    input wire [1:0] act_type,
    output reg [15:0] data_out,
    output reg valid_out
);

    reg signed [39:0] data_signed;
    reg signed [15:0] result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 16'd0;
            valid_out <= 1'b0;
            data_signed <= 40'd0;
            result <= 16'd0;
        end else begin
            valid_out <= valid;
            data_signed <= $signed(data_in);
            
            case (act_type)
                2'd0: begin
                    result <= data_signed[15:0];
                end
                
                2'd1: begin
                    if (data_signed < 0) begin
                        result <= 16'd0;
                    end else begin
                        result <= data_signed[15:0];
                    end
                end
                
                2'd2: begin
                    if (data_signed < 0) begin
                        result <= 16'd0;
                    end else if (data_signed > 6) begin
                        result <= 16'd6;
                    end else begin
                        result <= data_signed[15:0];
                    end
                end
                
                2'd3: begin
                    result <= 16'sd32768 / (1 + 2'sd2 ** (-data_signed[15:8]));
                end
                
                default: begin
                    result <= data_signed[15:0];
                end
            endcase
            
            if (valid) begin
                data_out <= result;
            end
        end
    end

endmodule
