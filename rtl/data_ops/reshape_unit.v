`include "../common/npu_definitions.vh"

module reshape_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:63],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out [0:63],
    output wire valid_out,
    input wire ready_out,
    
    input wire [5:0] input_shape [0:3],
    input wire [5:0] output_shape [0:3]
);

    reg [15:0] data_out_reg [0:63];
    reg valid_out_reg;
    reg ready_in_reg;
    reg [1:0] reshape_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 2'd0;
    localparam RESHAPE = 2'd1;
    localparam OUTPUT = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 64; i = i + 1) begin
                data_out_reg[i] <= {16{1'b0}};
            end
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            reshape_state <= IDLE;
        end else begin
            case (reshape_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        reshape_state <= RESHAPE;
                    end
                end
                
                RESHAPE: begin
                    ready_in_reg <= 1'b0;
                    for (integer i = 0; i < 64; i = i + 1) begin
                        data_out_reg[i] <= data_in[i];
                    end
                    reshape_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        reshape_state <= IDLE;
                    end
                end
                
                default: reshape_state <= IDLE;
            endcase
        end
    end

endmodule
