`include "../common/npu_definitions.vh"

module quantization_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in,
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    input wire [15:0] scale,
    input wire [15:0] zero_point,
    input wire [1:0] input_bits,
    input wire [1:0] output_bits
);

    reg [15:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [2:0] quant_state;
    reg signed [16*2-1:0] scaled;
    reg signed [16-1:0] quantized;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 3'd0;
    localparam SCALE = 3'd1;
    localparam QUANTIZE = 3'd2;
    localparam OUTPUT = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= {16{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            quant_state <= IDLE;
            scaled <= {16*2{1'b0}};
            quantized <= {16{1'b0}};
        end else begin
            case (quant_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        quant_state <= SCALE;
                    end
                end
                
                SCALE: begin
                    ready_in_reg <= 1'b0;
                    scaled <= $signed(data_in) * $signed(scale);
                    quant_state <= QUANTIZE;
                end
                
                QUANTIZE: begin
                    case (output_bits)
                        2'd0: quantized <= scaled[7:0] + $signed(zero_point);
                        2'd1: quantized <= scaled[15:0] + $signed(zero_point);
                        2'd2: quantized <= scaled[31:0] + $signed(zero_point);
                        default: quantized <= scaled[16-1:0] + $signed(zero_point);
                    endcase
                    data_out_reg <= quantized;
                    quant_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        quant_state <= IDLE;
                    end
                end
                
                default: quant_state <= IDLE;
            endcase
        end
    end

endmodule
