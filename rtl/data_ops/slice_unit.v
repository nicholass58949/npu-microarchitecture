`include "../common/npu_definitions.vh"

module slice_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:63],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out [0:15],
    output wire valid_out,
    input wire ready_out,
    
    input wire [5:0] start_idx,
    input wire [5:0] end_idx
);

    reg [15:0] data_out_reg [0:15];
    reg valid_out_reg;
    reg ready_in_reg;
    reg [1:0] slice_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 2'd0;
    localparam SLICE = 2'd1;
    localparam OUTPUT = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 16; i = i + 1) begin
                data_out_reg[i] <= {16{1'b0}};
            end
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            slice_state <= IDLE;
        end else begin
            case (slice_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        slice_state <= SLICE;
                    end
                end
                
                SLICE: begin
                    ready_in_reg <= 1'b0;
                    for (integer i = 0; i < 16; i = i + 1) begin
                        if (start_idx + i <= end_idx) begin
                            data_out_reg[i] <= data_in[start_idx + i];
                        end else begin
                            data_out_reg[i] <= {16{1'b0}};
                        end
                    end
                    slice_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        slice_state <= IDLE;
                    end
                end
                
                default: slice_state <= IDLE;
            endcase
        end
    end

endmodule
