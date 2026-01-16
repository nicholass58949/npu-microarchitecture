`include "../common/npu_definitions.vh"

module element_wise_op (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] operand_a,
    input wire [DATA_WIDTH-1:0] operand_b,
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    input wire [2:0] op_type
);

    reg [DATA_WIDTH-1:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [2:0] elem_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 3'd0;
    localparam COMPUTE = 3'd1;
    localparam OUTPUT = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= {DATA_WIDTH{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            elem_state <= IDLE;
        end else begin
            case (elem_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        elem_state <= COMPUTE;
                    end
                end
                
                COMPUTE: begin
                    ready_in_reg <= 1'b0;
                    case (op_type)
                        3'd0: data_out_reg <= operand_a + operand_b;
                        3'd1: data_out_reg <= operand_a - operand_b;
                        3'd2: data_out_reg <= operand_a * operand_b;
                        3'd3: data_out_reg <= operand_a / operand_b;
                        3'd4: data_out_reg <= operand_a & operand_b;
                        3'd5: data_out_reg <= operand_a | operand_b;
                        3'd6: data_out_reg <= operand_a ^ operand_b;
                        3'd7: data_out_reg <= ~operand_a;
                        default: data_out_reg <= operand_a;
                    endcase
                    elem_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        elem_state <= IDLE;
                    end
                end
                
                default: elem_state <= IDLE;
            endcase
        end
    end

endmodule
