`include "../common/npu_definitions.vh"

module concat_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in_a,
    input wire [15:0] data_in_b,
    input wire valid_in,
    output wire ready_in,
    output wire [16*2-1:0] data_out,
    output wire valid_out,
    input wire ready_out
);

    reg [16*2-1:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [1:0] concat_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 2'd0;
    localparam CONCAT = 2'd1;
    localparam OUTPUT = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= {16*2{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            concat_state <= IDLE;
        end else begin
            case (concat_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        concat_state <= CONCAT;
                    end
                end
                
                CONCAT: begin
                    ready_in_reg <= 1'b0;
                    data_out_reg <= {data_in_a, data_in_b};
                    concat_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        concat_state <= IDLE;
                    end
                end
                
                default: concat_state <= IDLE;
            endcase
        end
    end

endmodule
