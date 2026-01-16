`include "../common/npu_definitions.vh"

module noc_router (
    input wire clk,
    input wire rst_n,
    input wire [4:0] router_id,
    
    input wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out,
    input wire valid_in,
    output wire valid_out,
    output wire ready_in,
    input wire ready_out,
    
    input wire [DATA_WIDTH-1:0] router_data_in [PE_ROWS*PE_COLS-1:0],
    output wire [DATA_WIDTH-1:0] router_data_out [PE_ROWS*PE_COLS-1:0],
    input wire [4:0] router_dest [PE_ROWS*PE_COLS-1:0],
    input wire router_valid_in [PE_ROWS*PE_COLS-1:0],
    output wire router_valid_out [PE_ROWS*PE_COLS-1:0],
    output wire router_ready_in [PE_ROWS*PE_COLS-1:0],
    input wire router_ready_out [PE_ROWS*PE_COLS-1:0]
);

    reg [DATA_WIDTH-1:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [DATA_WIDTH-1:0] router_data_out_reg [PE_ROWS*PE_COLS-1:0];
    reg router_valid_out_reg [PE_ROWS*PE_COLS-1:0];
    reg router_ready_in_reg [PE_ROWS*PE_COLS-1:0];
    
    reg [2:0] router_state;
    reg [4:0] current_dest;
    reg [DATA_WIDTH-1:0] current_data;

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
            data_out_reg <= {DATA_WIDTH{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            router_state <= IDLE;
            current_dest <= 5'd0;
            current_data <= {DATA_WIDTH{1'b0}};
            
            for (integer i = 0; i < PE_ROWS*PE_COLS; i = i + 1) begin
                router_data_out_reg[i] <= {DATA_WIDTH{1'b0}};
                router_valid_out_reg[i] <= 1'b0;
                router_ready_in_reg[i] <= 1'b0;
            end
        end else begin
            case (router_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        current_data <= data_in;
                        current_dest <= data_in[4:0];
                        router_state <= ROUTE;
                    end
                    
                    for (integer i = 0; i < PE_ROWS*PE_COLS; i = i + 1) begin
                        if (router_valid_in[i] && router_dest[i] == router_id) begin
                            data_out_reg <= router_data_in[i];
                            valid_out_reg <= 1'b1;
                            router_ready_in_reg[i] <= 1'b1;
                        end else begin
                            router_ready_in_reg[i] <= 1'b0;
                        end
                    end
                    
                    if (valid_out_reg && ready_out) begin
                        valid_out_reg <= 1'b0;
                    end
                end
                
                ROUTE: begin
                    ready_in_reg <= 1'b0;
                    if (current_dest == router_id) begin
                        data_out_reg <= current_data;
                        valid_out_reg <= 1'b1;
                        router_state <= IDLE;
                    end else begin
                        router_data_out_reg[current_dest] <= current_data;
                        router_valid_out_reg[current_dest] <= 1'b1;
                        router_state <= FORWARD;
                    end
                end
                
                FORWARD: begin
                    if (router_ready_out[current_dest]) begin
                        router_valid_out_reg[current_dest] <= 1'b0;
                        router_state <= IDLE;
                    end
                end
                
                default: router_state <= IDLE;
            endcase
        end
    end

endmodule
