`include "../common/npu_definitions.vh"

module pooling_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:3],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    input wire [1:0] pool_type,
    input wire [1:0] kernel_size
);

    reg [15:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [2:0] pool_state;
    reg [15:0] max_val;
    reg signed [16+1:0] sum_val;

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
            pool_state <= IDLE;
            max_val <= {16{1'b0}};
            sum_val <= {16+2{1'b0}};
        end else begin
            case (pool_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        pool_state <= COMPUTE;
                    end
                end
                
                COMPUTE: begin
                    ready_in_reg <= 1'b0;
                    case (pool_type)
                        2'd1: begin
                            max_val <= data_in[0];
                            if (data_in[1] > max_val) max_val <= data_in[1];
                            if (data_in[2] > max_val) max_val <= data_in[2];
                            if (data_in[3] > max_val) max_val <= data_in[3];
                            data_out_reg <= max_val;
                        end
                        
                        2'd2: begin
                            sum_val <= $signed(data_in[0]) + $signed(data_in[1]) + 
                                      $signed(data_in[2]) + $signed(data_in[3]);
                            data_out_reg <= sum_val >> 2;
                        end
                        
                        default: begin
                            data_out_reg <= data_in[0];
                        end
                    endcase
                    pool_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        pool_state <= IDLE;
                    end
                end
                
                default: pool_state <= IDLE;
            endcase
        end
    end

endmodule
