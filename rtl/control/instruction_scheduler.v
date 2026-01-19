`include "../common/npu_definitions.vh"

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
    
    output wire [15:0] pe_array_input [0:63],
    input wire [15:0] pe_array_output [0:63],
    output reg pe_array_valid,
    input wire pe_array_ready,
    input wire pe_array_done,
    
    output reg conv_valid,
    input wire conv_ready,
    
    output reg matmul_valid,
    input wire matmul_ready,
    
    output reg pool_valid,
    input wire pool_ready,
    
    output reg activation_valid,
    input wire activation_ready,
    
    output reg bn_valid,
    input wire bn_ready,
    
    output reg softmax_valid,
    input wire softmax_ready,
    
    output reg elementwise_valid,
    input wire elementwise_ready,
    
    output reg concat_valid,
    input wire concat_ready,
    
    output reg reshape_valid,
    input wire reshape_ready,
    
    output reg transpose_valid,
    input wire transpose_ready,
    
    output reg reduction_valid,
    input wire reduction_ready,
    
    output reg broadcast_valid,
    input wire broadcast_ready,
    
    output reg slice_valid,
    input wire slice_ready,
    
    output reg tile_valid,
    input wire tile_ready,
    
    output reg pad_valid,
    input wire pad_ready,
    
    output reg quant_valid,
    input wire quant_ready,
    
    output reg dequant_valid,
    input wire dequant_ready,
    
    output reg rearrange_valid,
    input wire rearrange_ready,
    
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

    reg [3:0] scheduler_state;
    reg [2:0] current_opcode;
    reg [31:0] current_src_addr;
    reg [31:0] current_dst_addr;
    reg [31:0] current_param1;
    reg [31:0] current_param2;
    
    reg [15:0] pe_input_reg [0:63];
    reg [7:0] iteration_count;
    reg [5:0] current_pe;
    
    localparam IDLE = 4'd0;
    localparam FETCH = 4'd1;
    localparam DISPATCH = 4'd2;
    localparam EXECUTE = 4'd3;
    localparam STORE = 4'd4;
    localparam COMPLETE = 4'd5;

    assign pe_array_input = pe_input_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            task_valid <= 1'b0;
            pe_array_valid <= 1'b0;
            conv_valid <= 1'b0;
            matmul_valid <= 1'b0;
            pool_valid <= 1'b0;
            activation_valid <= 1'b0;
            bn_valid <= 1'b0;
            softmax_valid <= 1'b0;
            elementwise_valid <= 1'b0;
            concat_valid <= 1'b0;
            reshape_valid <= 1'b0;
            transpose_valid <= 1'b0;
            reduction_valid <= 1'b0;
            broadcast_valid <= 1'b0;
            slice_valid <= 1'b0;
            tile_valid <= 1'b0;
            pad_valid <= 1'b0;
            quant_valid <= 1'b0;
            dequant_valid <= 1'b0;
            rearrange_valid <= 1'b0;
            
            global_buffer_addr <= {32{1'b0}};
            global_buffer_wdata <= {16{1'b0}};
            global_buffer_we <= 1'b0;
            global_buffer_ce <= 1'b0;
            
            dma_addr <= {32{1'b0}};
            dma_wdata <= {16{1'b0}};
            dma_we <= 1'b0;
            dma_ce <= 1'b0;
            
            scheduler_state <= IDLE;
            current_opcode <= 3'd0;
            current_src_addr <= {32{1'b0}};
            current_dst_addr <= {32{1'b0}};
            current_param1 <= 32'd0;
            current_param2 <= 32'd0;
            iteration_count <= 8'd0;
            current_pe <= 5'd0;
        end else begin
            case (scheduler_state)
                IDLE: begin
                    if (task_start && task_ready) begin
                        task_valid <= 1'b1;
                        current_opcode <= opcode;
                        current_src_addr <= src_addr;
                        current_dst_addr <= dst_addr;
                        current_param1 <= param1;
                        current_param2 <= param2;
                        scheduler_state <= FETCH;
                    end
                end
                
                FETCH: begin
                    task_valid <= 1'b0;
                    global_buffer_addr <= current_src_addr;
                    global_buffer_ce <= 1'b1;
                    global_buffer_we <= 1'b0;
                    scheduler_state <= DISPATCH;
                end
                
                DISPATCH: begin
                    global_buffer_ce <= 1'b0;
                    case (current_opcode)
                        3'd0: begin
                            conv_valid <= 1'b1;
                            if (conv_ready) begin
                                conv_valid <= 1'b0;
                                scheduler_state <= EXECUTE;
                            end
                        end
                        
                        3'd1: begin
                            matmul_valid <= 1'b1;
                            if (matmul_ready) begin
                                matmul_valid <= 1'b0;
                                scheduler_state <= EXECUTE;
                            end
                        end
                        
                        3'd2: begin
                            pool_valid <= 1'b1;
                            if (pool_ready) begin
                                pool_valid <= 1'b0;
                                scheduler_state <= EXECUTE;
                            end
                        end
                        
                        3'd3: begin
                            activation_valid <= 1'b1;
                            if (activation_ready) begin
                                activation_valid <= 1'b0;
                                scheduler_state <= EXECUTE;
                            end
                        end
                        
                        3'd4: begin
                            bn_valid <= 1'b1;
                            if (bn_ready) begin
                                bn_valid <= 1'b0;
                                scheduler_state <= EXECUTE;
                            end
                        end
                        
                        3'd5: begin
                            reshape_valid <= 1'b1;
                            if (reshape_ready) begin
                                reshape_valid <= 1'b0;
                                scheduler_state <= EXECUTE;
                            end
                        end
                        
                        3'd6: begin
                            concat_valid <= 1'b1;
                            if (concat_ready) begin
                                concat_valid <= 1'b0;
                                scheduler_state <= EXECUTE;
                            end
                        end
                        
                        default: begin
                            scheduler_state <= EXECUTE;
                        end
                    endcase
                end
                
                EXECUTE: begin
                    case (current_opcode)
                        3'd0, 3'd1: begin
                            pe_input_reg[current_pe] <= global_buffer_rdata;
                            pe_array_valid <= 1'b1;
                            if (pe_array_ready) begin
                                pe_array_valid <= 1'b0;
                                if (current_pe < 6'd63) begin
                                    current_pe <= current_pe + 1'b1;
                                    global_buffer_addr <= current_src_addr + current_pe + 1'b1;
                                    global_buffer_ce <= 1'b1;
                                end else if (pe_array_done) begin
                                    current_pe <= 5'd0;
                                    scheduler_state <= STORE;
                                end
                            end
                        end
                        
                        3'd2: begin
                            if (pool_ready) begin
                                pool_valid <= 1'b0;
                                scheduler_state <= STORE;
                            end
                        end
                        
                        3'd3: begin
                            if (activation_ready) begin
                                activation_valid <= 1'b0;
                                scheduler_state <= STORE;
                            end
                        end
                        
                        3'd4: begin
                            if (bn_ready) begin
                                bn_valid <= 1'b0;
                                scheduler_state <= STORE;
                            end
                        end
                        
                        3'd5: begin
                            if (reshape_ready) begin
                                reshape_valid <= 1'b0;
                                scheduler_state <= STORE;
                            end
                        end
                        
                        3'd6: begin
                            if (concat_ready) begin
                                concat_valid <= 1'b0;
                                scheduler_state <= STORE;
                            end
                        end
                        
                        default: begin
                            scheduler_state <= STORE;
                        end
                    endcase
                end
                
                STORE: begin
                    global_buffer_addr <= current_dst_addr;
                    global_buffer_wdata <= pe_array_output[current_pe];
                    global_buffer_we <= 1'b1;
                    global_buffer_ce <= 1'b1;
                    scheduler_state <= COMPLETE;
                end
                
                COMPLETE: begin
                    global_buffer_we <= 1'b0;
                    global_buffer_ce <= 1'b0;
                    scheduler_state <= IDLE;
                end
                
                default: scheduler_state <= IDLE;
            endcase
        end
    end

endmodule
