`include "../common/npu_definitions.vh"

module activation_unit (
    input wire clk,
    input wire rst_n,
    input wire [ACC_WIDTH-1:0] data_in,
    input wire valid,
    input activation_type_t act_type,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg valid_out
);

    reg signed [ACC_WIDTH-1:0] data_signed;
    reg signed [DATA_WIDTH-1:0] result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {DATA_WIDTH{1'b0}};
            valid_out <= 1'b0;
            data_signed <= {ACC_WIDTH{1'b0}};
            result <= {DATA_WIDTH{1'b0}};
        end else begin
            valid_out <= valid;
            data_signed <= $signed(data_in);
            
            case (act_type)
                ACT_NONE: begin
                    result <= data_signed[DATA_WIDTH-1:0];
                end
                
                ACT_RELU: begin
                    if (data_signed < 0) begin
                        result <= {DATA_WIDTH{1'b0}};
                    end else begin
                        result <= data_signed[DATA_WIDTH-1:0];
                    end
                end
                
                ACT_RELU6: begin
                    if (data_signed < 0) begin
                        result <= {DATA_WIDTH{1'b0}};
                    end else if (data_signed > 6) begin
                        result <= 16'd6;
                    end else begin
                        result <= data_signed[DATA_WIDTH-1:0];
                    end
                end
                
                ACT_SIGMOID: begin
                    result <= 16'sd32768 / (1 + $signed(2'sb10) ** (-data_signed[15:8]));
                end
                
                default: begin
                    result <= data_signed[DATA_WIDTH-1:0];
                end
            endcase
            
            if (valid) begin
                data_out <= result;
            end
        end
    end

endmodule
