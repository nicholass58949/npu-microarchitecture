`include "../common/npu_definitions.vh"

module pad_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:63],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out [0:99],
    output wire valid_out,
    input wire ready_out,
    
    input wire [3:0] pad_top,
    input wire [3:0] pad_bottom,
    input wire [3:0] pad_left,
    input wire [3:0] pad_right,
    input wire [15:0] pad_value
);

    reg [15:0] data_out_reg [0:99];
    reg valid_out_reg;
    reg ready_in_reg;
    reg [1:0] pad_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 2'd0;
    localparam PAD = 2'd1;
    localparam OUTPUT = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 100; i = i + 1) begin
                data_out_reg[i] <= {16{1'b0}};
            end
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            pad_state <= IDLE;
        end else begin
            case (pad_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        pad_state <= PAD;
                    end
                end
                
                PAD: begin
                    ready_in_reg <= 1'b0;
                    for (integer i = 0; i < 100; i = i + 1) begin
                        data_out_reg[i] <= pad_value;
                    end
                    
                    for (integer i = 0; i < 64; i = i + 1) begin
                        data_out_reg[(i / 8 + pad_top) * 10 + (i % 8 + pad_left)] <= data_in[i];
                    end
                    pad_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        pad_state <= IDLE;
                    end
                end
                
                default: pad_state <= IDLE;
            endcase
        end
    end

endmodule
