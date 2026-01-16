`include "../common/npu_definitions.vh"

module dma_controller (
    input wire clk,
    input wire rst_n,
    
    input wire [ADDR_WIDTH-1:0] dram_addr,
    input wire [DATA_WIDTH-1:0] dram_wdata,
    output wire [DATA_WIDTH-1:0] dram_rdata,
    input wire dram_we,
    input wire dram_ce,
    output reg dram_ready,
    
    output wire [DATA_WIDTH-1:0] buffer_wdata,
    output wire [ADDR_WIDTH-1:0] buffer_addr,
    output wire buffer_we,
    output wire buffer_ce,
    input wire [DATA_WIDTH-1:0] buffer_rdata,
    
    output reg dma_done
);

    reg [ADDR_WIDTH-1:0] src_addr;
    reg [ADDR_WIDTH-1:0] dst_addr;
    reg [31:0] transfer_size;
    reg [2:0] dma_state;
    reg [31:0] transfer_count;
    reg [DATA_WIDTH-1:0] temp_data;

    assign buffer_wdata = dram_rdata;
    assign buffer_addr = dst_addr;
    assign buffer_we = (dma_state == 3'd2);
    assign buffer_ce = (dma_state != 3'd0);

    localparam IDLE = 3'd0;
    localparam READ_DRAM = 3'd1;
    localparam WRITE_BUFFER = 3'd2;
    localparam DONE = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dma_state <= IDLE;
            dram_ready <= 1'b0;
            dma_done <= 1'b0;
            src_addr <= {ADDR_WIDTH{1'b0}};
            dst_addr <= {ADDR_WIDTH{1'b0}};
            transfer_size <= 32'd0;
            transfer_count <= 32'd0;
            temp_data <= {DATA_WIDTH{1'b0}};
        end else begin
            case (dma_state)
                IDLE: begin
                    dram_ready <= 1'b1;
                    dma_done <= 1'b0;
                    if (dram_ce) begin
                        src_addr <= dram_addr;
                        dst_addr <= dram_addr;
                        transfer_size <= 32'd128;
                        transfer_count <= 32'd0;
                        dma_state <= READ_DRAM;
                    end
                end
                
                READ_DRAM: begin
                    dram_ready <= 1'b0;
                    if (dram_ce) begin
                        temp_data <= dram_rdata;
                        dma_state <= WRITE_BUFFER;
                    end
                end
                
                WRITE_BUFFER: begin
                    transfer_count <= transfer_count + 1'b1;
                    src_addr <= src_addr + 1'b1;
                    dst_addr <= dst_addr + 1'b1;
                    
                    if (transfer_count >= transfer_size) begin
                        dma_state <= DONE;
                    end else begin
                        dma_state <= READ_DRAM;
                    end
                end
                
                DONE: begin
                    dma_done <= 1'b1;
                    dram_ready <= 1'b1;
                    dma_state <= IDLE;
                end
                
                default: dma_state <= IDLE;
            endcase
        end
    end

endmodule
