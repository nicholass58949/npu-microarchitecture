`include "../common/npu_definitions.vh"

module softmax_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] data_in [0:7],
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] data_out [0:7],
    output wire valid_out,
    input wire ready_out
);

    reg [DATA_WIDTH-1:0] data_out_reg [0:7];
    reg valid_out_reg;
    reg ready_in_reg;
    reg [3:0] softmax_state;
    reg [DATA_WIDTH-1:0] max_val;
    reg signed [DATA_WIDTH*2-1:0] exp_sum;
    reg signed [DATA_WIDTH*2-1:0] exp_val [0:7];

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 4'd0;
    localparam FIND_MAX = 4'd1;
    localparam COMPUTE_EXP = 4'd2;
    localparam SUM_EXP = 4'd3;
    localparam NORMALIZE = 4'd4;
    localparam OUTPUT = 4'd5;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 8; i = i + 1) begin
                data_out_reg[i] <= {DATA_WIDTH{1'b0}};
                exp_val[i] <= {DATA_WIDTH*2{1'b0}};
            end
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            softmax_state <= IDLE;
            max_val <= {DATA_WIDTH{1'b0}};
            exp_sum <= {DATA_WIDTH*2{1'b0}};
        end else begin
            case (softmax_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        softmax_state <= FIND_MAX;
                    end
                end
                
                FIND_MAX: begin
                    ready_in_reg <= 1'b0;
                    max_val <= data_in[0];
                    for (integer i = 1; i < 8; i = i + 1) begin
                        if (data_in[i] > max_val) begin
                            max_val <= data_in[i];
                        end
                    end
                    softmax_state <= COMPUTE_EXP;
                end
                
                COMPUTE_EXP: begin
                    for (integer i = 0; i < 8; i = i + 1) begin
                        exp_val[i] <= $signed(2'sb10) ** ($signed(data_in[i]) - $signed(max_val));
                    end
                    softmax_state <= SUM_EXP;
                end
                
                SUM_EXP: begin
                    exp_sum <= exp_val[0];
                    for (integer i = 1; i < 8; i = i + 1) begin
                        exp_sum <= exp_sum + exp_val[i];
                    end
                    softmax_state <= NORMALIZE;
                end
                
                NORMALIZE: begin
                    for (integer i = 0; i < 8; i = i + 1) begin
                        data_out_reg[i] <= (exp_val[i] * 16'sd32768) / exp_sum;
                    end
                    softmax_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        softmax_state <= IDLE;
                    end
                end
                
                default: softmax_state <= IDLE;
            endcase
        end
    end

endmodule
