`include "../common/npu_definitions.vh"

module data_rearrange (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:15],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out [0:15],
    output wire valid_out,
    input wire ready_out,
    
    input wire [3:0] rearrange_mode
);

    reg [15:0] data_out_reg [0:15];
    reg valid_out_reg;
    reg ready_in_reg;
    reg [2:0] rearrange_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 3'd0;
    localparam REARRANGE = 3'd1;
    localparam OUTPUT = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 16; i = i + 1) begin
                data_out_reg[i] <= {16{1'b0}};
            end
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            rearrange_state <= IDLE;
        end else begin
            case (rearrange_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        rearrange_state <= REARRANGE;
                    end
                end
                
                REARRANGE: begin
                    ready_in_reg <= 1'b0;
                    case (rearrange_mode)
                        4'd0: begin
                            for (integer i = 0; i < 16; i = i + 1) begin
                                data_out_reg[i] <= data_in[i];
                            end
                        end
                        4'd1: begin
                            for (integer i = 0; i < 16; i = i + 1) begin
                                data_out_reg[i] <= data_in[15-i];
                            end
                        end
                        4'd2: begin
                            for (integer i = 0; i < 16; i = i + 1) begin
                                data_out_reg[i] <= data_in[(i*4) % 16 + i/4];
                            end
                        end
                        default: begin
                            for (integer i = 0; i < 16; i = i + 1) begin
                                data_out_reg[i] <= data_in[i];
                            end
                        end
                    endcase
                    rearrange_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        rearrange_state <= IDLE;
                    end
                end
                
                default: rearrange_state <= IDLE;
            endcase
        end
    end

endmodule
