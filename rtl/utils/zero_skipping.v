`include "../common/npu_definitions.vh"

module zero_skipping (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in,
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    output wire skip_flag
);

    reg [15:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg skip_flag_reg;
    reg [1:0] skip_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;
    assign skip_flag = skip_flag_reg;

    localparam IDLE = 2'd0;
    localparam CHECK = 2'd1;
    localparam OUTPUT = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= {16{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            skip_flag_reg <= 1'b0;
            skip_state <= IDLE;
        end else begin
            case (skip_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        skip_state <= CHECK;
                    end
                end
                
                CHECK: begin
                    ready_in_reg <= 1'b0;
                    if (data_in == {16{1'b0}}) begin
                        skip_flag_reg <= 1'b1;
                        data_out_reg <= {16{1'b0}};
                        valid_out_reg <= 1'b0;
                        skip_state <= IDLE;
                    end else begin
                        skip_flag_reg <= 1'b0;
                        data_out_reg <= data_in;
                        skip_state <= OUTPUT;
                    end
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        skip_state <= IDLE;
                    end
                end
                
                default: skip_state <= IDLE;
            endcase
        end
    end

endmodule
