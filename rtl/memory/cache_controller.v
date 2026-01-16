`include "../common/npu_definitions.vh"

module cache_controller (
    input wire clk,
    input wire rst_n,
    
    input wire [ADDR_WIDTH-1:0] cpu_addr,
    input wire [DATA_WIDTH-1:0] cpu_wdata,
    output wire [DATA_WIDTH-1:0] cpu_rdata,
    input wire cpu_we,
    input wire cpu_ce,
    output wire cpu_ready,
    
    output wire [ADDR_WIDTH-1:0] mem_addr,
    input wire [DATA_WIDTH-1:0] mem_rdata,
    output wire mem_ce
);

    parameter CACHE_SIZE = 256;
    parameter LINE_SIZE = 4;

    reg [DATA_WIDTH-1:0] cache_data [0:CACHE_SIZE-1];
    reg [ADDR_WIDTH-1:0] cache_tag [0:63];
    reg [63:0] cache_valid;
    reg [63:0] cache_dirty;
    
    reg [DATA_WIDTH-1:0] cpu_rdata_reg;
    reg cpu_ready_reg;
    reg [2:0] cache_state;
    
    reg [ADDR_WIDTH-1:0] current_addr;
    reg [5:0] cache_index;
    reg [ADDR_WIDTH-1:6] cache_tag_in;
    reg [1:0] cache_offset;

    assign cpu_rdata = cpu_rdata_reg;
    assign cpu_ready = cpu_ready_reg;
    assign mem_addr = {cache_tag_in, cache_index, 2'b00};
    assign mem_ce = (cache_state == 3'd2);

    localparam IDLE = 3'd0;
    localparam CHECK_CACHE = 3'd1;
    localparam FETCH_LINE = 3'd2;
    localparam UPDATE_CACHE = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cache_state <= IDLE;
            cpu_ready_reg <= 1'b1;
            cpu_rdata_reg <= {DATA_WIDTH{1'b0}};
            cache_valid <= 64'd0;
            cache_dirty <= 64'd0;
            current_addr <= {ADDR_WIDTH{1'b0}};
        end else begin
            case (cache_state)
                IDLE: begin
                    cpu_ready_reg <= 1'b1;
                    if (cpu_ce) begin
                        current_addr <= cpu_addr;
                        cache_index <= cpu_addr[7:2];
                        cache_tag_in <= cpu_addr[ADDR_WIDTH-1:8];
                        cache_offset <= cpu_addr[1:0];
                        cache_state <= CHECK_CACHE;
                    end
                end
                
                CHECK_CACHE: begin
                    cpu_ready_reg <= 1'b0;
                    if (cache_valid[cache_index] && cache_tag[cache_index] == cache_tag_in) begin
                        cpu_rdata_reg <= cache_data[cache_index * LINE_SIZE + cache_offset];
                        cache_state <= IDLE;
                    end else begin
                        cache_state <= FETCH_LINE;
                    end
                end
                
                FETCH_LINE: begin
                    cache_state <= UPDATE_CACHE;
                end
                
                UPDATE_CACHE: begin
                    cache_data[cache_index * LINE_SIZE] <= mem_rdata;
                    cache_tag[cache_index] <= cache_tag_in;
                    cache_valid[cache_index] <= 1'b1;
                    cpu_rdata_reg <= mem_rdata;
                    cache_state <= IDLE;
                end
                
                default: cache_state <= IDLE;
            endcase
        end
    end

endmodule
