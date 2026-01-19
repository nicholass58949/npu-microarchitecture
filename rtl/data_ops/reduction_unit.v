`include "../common/npu_definitions.vh"

module reduction_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:15],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    input wire [2:0] reduction_type
);

    reg [15:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [2:0] reduction_state;
    reg signed [16+3:0] sum_val;
    reg [15:0] max_val;
    reg [15:0] min_val;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 3'd0;
    localparam COMPUTE = 3'd1;
    localparam OUTPUT = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= {16{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            reduction_state <= IDLE;
            sum_val <= {16+4{1'b0}};
            max_val <= {16{1'b0}};
            min_val <= {16{1'b1}};
        end else begin
            case (reduction_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        reduction_state <= COMPUTE;
                    end
                end
                
                COMPUTE: begin
                    ready_in_reg <= 1'b0;
                    case (reduction_type)
                        3'd0: begin
                            sum_val <= $signed(data_in[0]);
                            for (integer i = 1; i < 16; i = i + 1) begin
                                sum_val <= sum_val + $signed(data_in[i]);
                            end
                            data_out_reg <= sum_val[16-1:0];
                        end
                        3'd1: begin
                            max_val <= data_in[0];
                            for (integer i = 1; i < 16; i = i + 1) begin
                                if (data_in[i] > max_val) begin
                                    max_val <= data_in[i];
                                end
                            end
                            data_out_reg <= max_val;
                        end
                        3'd2: begin
                            min_val <= data_in[0];
                            for (integer i = 1; i < 16; i = i + 1) begin
                                if (data_in[i] < min_val) begin
                                    min_val <= data_in[i];
                                end
                            end
                            data_out_reg <= min_val;
                        end
                        3'd3: begin
                            sum_val <= $signed(data_in[0]);
                            for (integer i = 1; i < 16; i = i + 1) begin
                                sum_val <= sum_val + $signed(data_in[i]);
                            end
                            data_out_reg <= sum_val >> 4;
                        end
                        default: begin
                            data_out_reg <= data_in[0];
                        end
                    endcase
                    reduction_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        reduction_state <= IDLE;
                    end
                end
                
                default: reduction_state <= IDLE;
            endcase
        end
    end

endmodule
