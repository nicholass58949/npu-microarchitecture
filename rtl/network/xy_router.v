`include "../common/npu_definitions.vh"

module xy_router (
    input wire clk,
    input wire rst_n,
    input wire [4:0] router_x,
    input wire [4:0] router_y,
    
    input wire [DATA_WIDTH-1:0] data_in_north,
    input wire valid_in_north,
    output wire ready_in_north,
    output wire [DATA_WIDTH-1:0] data_out_north,
    output wire valid_out_north,
    input wire ready_out_north,
    
    input wire [DATA_WIDTH-1:0] data_in_south,
    input wire valid_in_south,
    output wire ready_in_south,
    output wire [DATA_WIDTH-1:0] data_out_south,
    output wire valid_out_south,
    input wire ready_out_south,
    
    input wire [DATA_WIDTH-1:0] data_in_east,
    input wire valid_in_east,
    output wire ready_in_east,
    output wire [DATA_WIDTH-1:0] data_out_east,
    output wire valid_out_east,
    input wire ready_out_east,
    
    input wire [DATA_WIDTH-1:0] data_in_west,
    input wire valid_in_west,
    output wire ready_in_west,
    output wire [DATA_WIDTH-1:0] data_out_west,
    output wire valid_out_west,
    input wire ready_out_west
);

    reg [DATA_WIDTH-1:0] data_out_north_reg, data_out_south_reg;
    reg [DATA_WIDTH-1:0] data_out_east_reg, data_out_west_reg;
    reg valid_out_north_reg, valid_out_south_reg;
    reg valid_out_east_reg, valid_out_west_reg;
    reg ready_in_north_reg, ready_in_south_reg;
    reg ready_in_east_reg, ready_in_west_reg;
    
    reg [4:0] dest_x, dest_y;
    reg [2:0] routing_state;

    assign data_out_north = data_out_north_reg;
    assign data_out_south = data_out_south_reg;
    assign data_out_east = data_out_east_reg;
    assign data_out_west = data_out_west_reg;
    assign valid_out_north = valid_out_north_reg;
    assign valid_out_south = valid_out_south_reg;
    assign valid_out_east = valid_out_east_reg;
    assign valid_out_west = valid_out_west_reg;
    assign ready_in_north = ready_in_north_reg;
    assign ready_in_south = ready_in_south_reg;
    assign ready_in_east = ready_in_east_reg;
    assign ready_in_west = ready_in_west_reg;

    localparam IDLE = 3'd0;
    localparam ROUTE_X = 3'd1;
    localparam ROUTE_Y = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_north_reg <= {DATA_WIDTH{1'b0}};
            data_out_south_reg <= {DATA_WIDTH{1'b0}};
            data_out_east_reg <= {DATA_WIDTH{1'b0}};
            data_out_west_reg <= {DATA_WIDTH{1'b0}};
            valid_out_north_reg <= 1'b0;
            valid_out_south_reg <= 1'b0;
            valid_out_east_reg <= 1'b0;
            valid_out_west_reg <= 1'b0;
            ready_in_north_reg <= 1'b1;
            ready_in_south_reg <= 1'b1;
            ready_in_east_reg <= 1'b1;
            ready_in_west_reg <= 1'b1;
            dest_x <= 5'd0;
            dest_y <= 5'd0;
            routing_state <= IDLE;
        end else begin
            case (routing_state)
                IDLE: begin
                    if (valid_in_north && ready_in_north_reg) begin
                        dest_x <= data_in_north[9:5];
                        dest_y <= data_in_north[4:0];
                        routing_state <= ROUTE_X;
                    end else if (valid_in_south && ready_in_south_reg) begin
                        dest_x <= data_in_south[9:5];
                        dest_y <= data_in_south[4:0];
                        routing_state <= ROUTE_X;
                    end else if (valid_in_east && ready_in_east_reg) begin
                        dest_x <= data_in_east[9:5];
                        dest_y <= data_in_east[4:0];
                        routing_state <= ROUTE_X;
                    end else if (valid_in_west && ready_in_west_reg) begin
                        dest_x <= data_in_west[9:5];
                        dest_y <= data_in_west[4:0];
                        routing_state <= ROUTE_X;
                    end
                end
                
                ROUTE_X: begin
                    if (dest_x > router_x) begin
                        data_out_east_reg <= data_in_west;
                        valid_out_east_reg <= 1'b1;
                        if (ready_out_east) begin
                            valid_out_east_reg <= 1'b0;
                            routing_state <= IDLE;
                        end
                    end else if (dest_x < router_x) begin
                        data_out_west_reg <= data_in_east;
                        valid_out_west_reg <= 1'b1;
                        if (ready_out_west) begin
                            valid_out_west_reg <= 1'b0;
                            routing_state <= IDLE;
                        end
                    end else begin
                        routing_state <= ROUTE_Y;
                    end
                end
                
                ROUTE_Y: begin
                    if (dest_y > router_y) begin
                        data_out_south_reg <= data_in_north;
                        valid_out_south_reg <= 1'b1;
                        if (ready_out_south) begin
                            valid_out_south_reg <= 1'b0;
                            routing_state <= IDLE;
                        end
                    end else if (dest_y < router_y) begin
                        data_out_north_reg <= data_in_south;
                        valid_out_north_reg <= 1'b1;
                        if (ready_out_north) begin
                            valid_out_north_reg <= 1'b0;
                            routing_state <= IDLE;
                        end
                    end else begin
                        routing_state <= IDLE;
                    end
                end
                
                default: routing_state <= IDLE;
            endcase
        end
    end

endmodule
