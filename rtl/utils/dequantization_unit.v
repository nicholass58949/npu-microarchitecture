`include "../common/npu_definitions.vh"

module dequantization_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    input wire [DATA_WIDTH-1:0] scale,
    input wire [DATA_WIDTH-1:0] zero_point
);

    reg [DATA_WIDTH-1:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [1:0] dequant_state;
    reg signed [DATA_WIDTH*2-1:0] dequantized;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 2'd0;
    localparam DEQUANTIZE = 2'd1;
    localparam OUTPUT = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= {DATA_WIDTH{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            dequant_state <= IDLE;
            dequantized <= {DATA_WIDTH*2{1'b0}};
        end else begin
            case (dequant_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        dequant_state <= DEQUANTIZE;
                    end
                end
                
                DEQUANTIZE: begin
                    ready_in_reg <= 1'b0;
                    dequantized <= ($signed(data_in) - $signed(zero_point)) * $signed(scale);
                    data_out_reg <= dequantized[DATA_WIDTH-1:0];
                    dequant_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        dequant_state <= IDLE;
                    end
                end
                
                default: dequant_state <= IDLE;
            endcase
        end
    end

endmodule
