`include "../common/npu_definitions.vh"

module batch_normalization (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    input wire [DATA_WIDTH-1:0] gamma,
    input wire [DATA_WIDTH-1:0] beta,
    input wire [DATA_WIDTH-1:0] mean,
    input wire [DATA_WIDTH-1:0] variance
);

    reg [DATA_WIDTH-1:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [2:0] bn_state;
    reg signed [DATA_WIDTH*2-1:0] normalized;
    reg signed [DATA_WIDTH*2-1:0] temp;

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
            bn_state <= IDLE;
            normalized <= {DATA_WIDTH*2{1'b0}};
            temp <= {DATA_WIDTH*2{1'b0}};
        end else begin
            case (bn_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        bn_state <= COMPUTE;
                    end
                end
                
                COMPUTE: begin
                    ready_in_reg <= 1'b0;
                    temp <= ($signed(data_in) - $signed(mean)) * $signed(gamma);
                    normalized <= temp / ($signed(variance) + 16'sd1);
                    data_out_reg <= normalized[DATA_WIDTH-1:0] + $signed(beta);
                    bn_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        bn_state <= IDLE;
                    end
                end
                
                default: bn_state <= IDLE;
            endcase
        end
    end

endmodule
