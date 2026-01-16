`include "../common/npu_definitions.vh"

module task_manager (
    input wire clk,
    input wire rst_n,
    
    input wire [31:0] task_id,
    input wire [31:0] task_addr,
    input wire [31:0] task_size,
    input wire task_valid,
    output reg task_ready,
    
    output wire [31:0] active_task_id,
    output wire task_active,
    output wire task_complete
);

    reg [31:0] task_queue_id [0:7];
    reg [31:0] task_queue_addr [0:7];
    reg [31:0] task_queue_size [0:7];
    reg [7:0] task_queue_valid;
    reg [2:0] task_wr_ptr, task_rd_ptr;
    reg task_full, task_empty;
    
    reg [31:0] current_task_id;
    reg [31:0] current_task_addr;
    reg [31:0] current_task_size;
    reg [2:0] task_state;
    reg [31:0] bytes_processed;

    assign active_task_id = current_task_id;
    assign task_active = (task_state != 3'd0);
    assign task_complete = (task_state == 3'd3);

    localparam IDLE = 3'd0;
    localparam FETCH = 3'd1;
    localparam PROCESS = 3'd2;
    localparam DONE = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            task_wr_ptr <= 3'd0;
            task_rd_ptr <= 3'd0;
            task_full <= 1'b0;
            task_empty <= 1'b1;
            task_queue_valid <= 8'd0;
            task_ready <= 1'b1;
            task_state <= IDLE;
            current_task_id <= 32'd0;
            current_task_addr <= 32'd0;
            current_task_size <= 32'd0;
            bytes_processed <= 32'd0;
        end else begin
            case (task_state)
                IDLE: begin
                    task_ready <= 1'b1;
                    if (task_valid && task_ready) begin
                        task_queue_id[task_wr_ptr] <= task_id;
                        task_queue_addr[task_wr_ptr] <= task_addr;
                        task_queue_size[task_wr_ptr] <= task_size;
                        task_queue_valid[task_wr_ptr] <= 1'b1;
                        task_wr_ptr <= task_wr_ptr + 1'b1;
                        task_empty <= 1'b0;
                        if (task_wr_ptr == 3'd7) begin
                            task_full <= 1'b1;
                        end
                    end
                    
                    if (~task_empty) begin
                        current_task_id <= task_queue_id[task_rd_ptr];
                        current_task_addr <= task_queue_addr[task_rd_ptr];
                        current_task_size <= task_queue_size[task_rd_ptr];
                        task_queue_valid[task_rd_ptr] <= 1'b0;
                        task_rd_ptr <= task_rd_ptr + 1'b1;
                        task_full <= 1'b0;
                        if (task_rd_ptr == 3'd7) begin
                            task_empty <= 1'b1;
                        end
                        bytes_processed <= 32'd0;
                        task_state <= FETCH;
                    end
                end
                
                FETCH: begin
                    task_state <= PROCESS;
                end
                
                PROCESS: begin
                    bytes_processed <= bytes_processed + 32'd64;
                    if (bytes_processed >= current_task_size) begin
                        task_state <= DONE;
                    end
                end
                
                DONE: begin
                    task_state <= IDLE;
                end
                
                default: task_state <= IDLE;
            endcase
        end
    end

endmodule
