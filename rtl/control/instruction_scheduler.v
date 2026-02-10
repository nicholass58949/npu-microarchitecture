`include "../common/npu_definitions.vh"

// Simplified Instruction Scheduler
// Only controls PE array and memory operations

module instruction_scheduler (
    input wire clk,
    input wire rst_n,
    
    input wire [31:0] task_id,
    input wire task_start,
    output reg task_valid,
    input wire task_ready,
    
    input wire [2:0] opcode,
    input wire [31:0] src_addr,
    input wire [31:0] dst_addr,
    input wire [31:0] param1,
    input wire [31:0] param2,
    
    output reg [15:0] pe_array_input [0:63],
    input wire [15:0] pe_array_output [0:63],
    output reg pe_array_valid,
    input wire pe_array_ready,
    input wire pe_array_done,
    
    output reg [31:0] global_buffer_addr,
    output reg [15:0] global_buffer_wdata,
    output reg global_buffer_we,
    output reg global_buffer_ce,
    input wire [15:0] global_buffer_rdata,
    
    output reg [31:0] dma_addr,
    output reg [15:0] dma_wdata,
    output reg dma_we,
    output reg dma_ce,
    input wire [15:0] dma_rdata,
    input wire dma_done,
    input wire dma_busy
);

    // Operation codes (simplified)
    localparam OP_LOAD = 3'b000;
    localparam OP_COMPUTE = 3'b001;
    localparam OP_STORE = 3'b010;
    localparam OP_NOP = 3'b111;
    
    reg [31:0] data_counter;
    reg [31:0] current_addr;
    reg state;
    integer i;
    
    localparam STATE_IDLE = 1'b0;
    localparam STATE_ACTIVE = 1'b1;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            task_valid <= 1'b0;
            pe_array_valid <= 1'b0;
            global_buffer_we <= 1'b0;
            global_buffer_ce <= 1'b0;
            dma_we <= 1'b0;
            dma_ce <= 1'b0;
            data_counter <= 32'd0;
            current_addr <= 32'd0;
            state <= STATE_IDLE;
            
            // Initialize PE array input
            for (i = 0; i < 64; i = i + 1)
                pe_array_input[i] <= 16'h0001 + i;
        end else begin
            // Default: all valid signals low
            task_valid <= 1'b0;
            pe_array_valid <= 1'b0;
            global_buffer_we <= 1'b0;
            global_buffer_ce <= 1'b0;
            dma_we <= 1'b0;
            dma_ce <= 1'b0;
            
            case (state)
                STATE_IDLE: begin
                    if (task_start) begin
                        state <= STATE_ACTIVE;
                        current_addr <= src_addr;
                        data_counter <= 32'd0;
                    end
                end
                
                STATE_ACTIVE: begin
                    case (opcode)
                        OP_LOAD: begin
                            // Load from DMA to global buffer
                            dma_ce <= 1'b1;
                            dma_addr <= current_addr;
                            
                            if (dma_done) begin  // FIX: Simplified completion check
                                global_buffer_ce <= 1'b1;
                                global_buffer_we <= 1'b1;
                                global_buffer_addr <= current_addr;
                                global_buffer_wdata <= dma_rdata;
                                
                                if (data_counter < param1 - 1) begin
                                    data_counter <= data_counter + 1'b1;
                                    current_addr <= current_addr + 32'd2;  // 16-bit = 2 bytes
                                end else begin
                                    state <= STATE_IDLE;
                                    task_valid <= 1'b1;
                                end
                            end
                        end
                        
                        OP_COMPUTE: begin
                            // Trigger PE array computation
                            pe_array_valid <= 1'b1;
                            
                            if (pe_array_ready && pe_array_done) begin
                                state <= STATE_IDLE;
                                task_valid <= 1'b1;
                                data_counter <= 32'd0;
                            end
                        end
                        
                        OP_STORE: begin
                            // Store from global buffer to DMA
                            global_buffer_ce <= 1'b1;
                            global_buffer_addr <= current_addr;
                            
                            dma_ce <= 1'b1;
                            dma_we <= 1'b1;
                            dma_addr <= dst_addr;
                            dma_wdata <= global_buffer_rdata;
                            
                            if (data_counter < param1 - 1) begin
                                data_counter <= data_counter + 1'b1;
                                current_addr <= current_addr + 32'd2;  // 16-bit = 2 bytes
                            end else begin
                                state <= STATE_IDLE;
                                task_valid <= 1'b1;
                            end
                        end
                        
                        default: begin
                            // NOP
                            state <= STATE_IDLE;
                            task_valid <= 1'b1;
                        end
                    endcase
                end
            endcase
        end
    end

endmodule
