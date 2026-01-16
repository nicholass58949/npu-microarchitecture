`include "../common/npu_definitions.vh"

module mac_unit (
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] operand_a,
    input wire [DATA_WIDTH-1:0] operand_b,
    input wire [ACC_WIDTH-1:0] accumulator_in,
    input wire valid,
    input wire rst_acc,
    output reg [ACC_WIDTH-1:0] accumulator_out,
    output reg done
);

    reg [MAC_WIDTH-1:0] product;
    reg [ACC_WIDTH-1:0] sum;
    reg [2:0] state;

    localparam IDLE = 3'd0;
    localparam MULTIPLY = 3'd1;
    localparam ACCUMULATE = 3'd2;
    localparam DONE = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product <= {MAC_WIDTH{1'b0}};
            sum <= {ACC_WIDTH{1'b0}};
            accumulator_out <= {ACC_WIDTH{1'b0}};
            done <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (valid) begin
                        if (rst_acc) begin
                            accumulator_out <= {ACC_WIDTH{1'b0}};
                        end
                        state <= MULTIPLY;
                    end
                end
                
                MULTIPLY: begin
                    product <= $signed(operand_a) * $signed(operand_b);
                    state <= ACCUMULATE;
                end
                
                ACCUMULATE: begin
                    sum <= accumulator_in + product;
                    state <= DONE;
                end
                
                DONE: begin
                    accumulator_out <= sum;
                    done <= 1'b1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
