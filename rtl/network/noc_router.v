`include "../common/npu_definitions.vh"

module noc_router (
    input wire clk,
    input wire rst_n,
    input wire [5:0] router_id,
    
    input wire [15:0] data_in,
    output wire [15:0] data_out,
    input wire valid_in,
    output wire valid_out,
    output wire ready_in,
    input wire ready_out,
    
    input wire [15:0] router_data_in [0:63],
    output wire [15:0] router_data_out [0:63],
    input wire [5:0] router_dest [0:63],
    input wire router_valid_in [0:63],
    output wire router_valid_out [0:63],
    output wire router_ready_in [0:63],
    input wire router_ready_out [0:63]
);

    reg [15:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [15:0] router_data_out_reg [0:63];
    reg router_valid_out_reg [0:63];
    reg router_ready_in_reg [0:63];
    
    reg [2:0] router_state;
    reg [4:0] current_dest;
    reg [15:0] current_data;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;
    assign router_data_out = router_data_out_reg;
    assign router_valid_out = router_valid_out_reg;
    assign router_ready_in = router_ready_in_reg;

    localparam IDLE = 3'd0;
    localparam ROUTE = 3'd1;
    localparam FORWARD = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= 16'd0;
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
        end else begin
            if (valid_in && ready_in_reg) begin
                current_data <= data_in;
                router_state <= ROUTE;
            end
            
            case (router_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                end
                
                ROUTE: begin
                    ready_in_reg <= 1'b0;
                    valid_out_reg <= 1'b1;
                    data_out_reg <= current_data;
                    router_state <= FORWARD;
                end
                
                FORWARD: begin
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        router_state <= IDLE;
                    end
                end
                
                default: router_state <= IDLE;
            endcase
        end
    end

endmodule
