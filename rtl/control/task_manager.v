`include "../common/npu_definitions.vh"

module task_manager (
    input wire clk,
    input wire rst_n,
    
    input wire [31:0] decoded_cmd,
    input wire decode_valid,
    output reg decode_ready,
    
    output reg [31:0] task_id,
    output reg task_start,
    output reg task_valid,
    input wire task_ready,
    output reg task_done
);

    reg [31:0] task_queue_id [0:7];
    reg [2:0] task_wr_ptr, task_rd_ptr;
    reg task_full, task_empty;
    reg [2:0] task_state;
    
    reg [31:0] current_task_id;
    reg [31:0] current_cmd;

    assign task_done = (task_state == 3'd3);

    localparam IDLE = 3'd0;
    localparam DECODE = 3'd1;
    localparam DISPATCH = 3'd2;
    localparam COMPLETE = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            decode_ready <= 1'b1;
            task_valid <= 1'b0;
            task_start <= 1'b0;
            task_id <= 32'd0;
            task_wr_ptr <= 3'd0;
            task_rd_ptr <= 3'd0;
            task_full <= 1'b0;
            task_empty <= 1'b1;
            task_state <= IDLE;
            current_task_id <= 32'd0;
            current_cmd <= 32'd0;
        end else begin
            case (task_state)
                IDLE: begin
                    decode_ready <= 1'b1;
                    task_valid <= 1'b0;
                    task_start <= 1'b0;
                    if (decode_valid && decode_ready) begin
                        task_queue_id[task_wr_ptr] <= decoded_cmd;
                        task_wr_ptr <= task_wr_ptr + 1'b1;
                        task_empty <= 1'b0;
                        if (task_wr_ptr == 3'd7) begin
                            task_full <= 1'b1;
                        end
                    end
                    
                    if (~task_empty) begin
                        current_task_id <= task_queue_id[task_rd_ptr];
                        current_cmd <= task_queue_id[task_rd_ptr];
                        task_rd_ptr <= task_rd_ptr + 1'b1;
                        task_full <= 1'b0;
                        if (task_rd_ptr == 3'd7) begin
                            task_empty <= 1'b1;
                        end
                        task_state <= DECODE;
                    end
                end
                
                DECODE: begin
                    decode_ready <= 1'b0;
                    task_id <= current_cmd;
                    task_state <= DISPATCH;
                end
                
                DISPATCH: begin
                    task_valid <= 1'b1;
                    task_start <= 1'b1;
                    if (task_ready) begin
                        task_valid <= 1'b0;
                        task_start <= 1'b0;
                        task_state <= COMPLETE;
                    end
                end
                
                COMPLETE: begin
                    task_state <= IDLE;
                end
                
                default: task_state <= IDLE;
            endcase
        end
    end

endmodule
