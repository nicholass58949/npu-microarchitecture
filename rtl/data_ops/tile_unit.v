`include "../common/npu_definitions.vh"

module tile_unit (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] data_in [0:63],
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] data_out [0:255],
    output wire valid_out,
    input wire ready_out,
    
    input wire [3:0] repeat_factor
);

    reg [DATA_WIDTH-1:0] data_out_reg [0:255];
    reg valid_out_reg;
    reg ready_in_reg;
    reg [2:0] tile_state;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 3'd0;
    localparam TILE = 3'd1;
    localparam OUTPUT = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 256; i = i + 1) begin
                data_out_reg[i] <= {DATA_WIDTH{1'b0}};
            end
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            tile_state <= IDLE;
        end else begin
            case (tile_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        tile_state <= TILE;
                    end
                end
                
                TILE: begin
                    ready_in_reg <= 1'b0;
                    for (integer i = 0; i < 64; i = i + 1) begin
                        for (integer j = 0; j < repeat_factor; j = j + 1) begin
                            data_out_reg[i * repeat_factor + j] <= data_in[i];
                        end
                    end
                    tile_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        tile_state <= IDLE;
                    end
                end
                
                default: tile_state <= IDLE;
            endcase
        end
    end

endmodule
