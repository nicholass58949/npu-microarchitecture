`include "../common/npu_definitions.vh"

module instruction_scheduler (
    input wire clk,
    input wire rst_n,
    
    input wire [31:0] cmd,
    input wire cmd_valid,
    output reg cmd_ready,
    
    output wire [DATA_WIDTH-1:0] pe_array_input [PE_ROWS*PE_COLS-1:0],
    input wire [DATA_WIDTH-1:0] pe_array_output [PE_ROWS*PE_COLS-1:0],
    output wire pe_array_valid,
    input wire pe_array_ready
);

    reg [31:0] cmd_fifo [0:31];
    reg [4:0] cmd_wr_ptr, cmd_rd_ptr;
    reg cmd_full, cmd_empty;
    
    reg [DATA_WIDTH-1:0] pe_input_reg [PE_ROWS*PE_COLS-1:0];
    reg pe_valid_reg;
    reg [2:0] scheduler_state;
    
    reg [31:0] current_cmd;
    reg [4:0] current_pe;
    reg [7:0] iteration_count;

    assign pe_array_input = pe_input_reg;
    assign pe_array_valid = pe_valid_reg;

    localparam IDLE = 3'd0;
    localparam DECODE = 3'd1;
    localparam DISPATCH = 3'd2;
    localparam WAIT = 3'd3;
    localparam COMPLETE = 3'd4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd_wr_ptr <= 5'd0;
            cmd_rd_ptr <= 5'd0;
            cmd_full <= 1'b0;
            cmd_empty <= 1'b1;
            cmd_ready <= 1'b1;
            pe_valid_reg <= 1'b0;
            scheduler_state <= IDLE;
            current_cmd <= 32'd0;
            current_pe <= 5'd0;
            iteration_count <= 8'd0;
        end else begin
            case (scheduler_state)
                IDLE: begin
                    cmd_ready <= 1'b1;
                    if (cmd_valid && cmd_ready) begin
                        cmd_fifo[cmd_wr_ptr] <= cmd;
                        cmd_wr_ptr <= cmd_wr_ptr + 1'b1;
                        cmd_empty <= 1'b0;
                        if (cmd_wr_ptr == 5'd31) begin
                            cmd_full <= 1'b1;
                        end
                    end
                    
                    if (~cmd_empty) begin
                        current_cmd <= cmd_fifo[cmd_rd_ptr];
                        cmd_rd_ptr <= cmd_rd_ptr + 1'b1;
                        cmd_full <= 1'b0;
                        if (cmd_rd_ptr == 5'd31) begin
                            cmd_empty <= 1'b1;
                        end
                        scheduler_state <= DECODE;
                    end
                end
                
                DECODE: begin
                    current_pe <= current_cmd[4:0];
                    iteration_count <= current_cmd[12:5];
                    scheduler_state <= DISPATCH;
                end
                
                DISPATCH: begin
                    pe_input_reg[current_pe] <= current_cmd[31:16];
                    pe_valid_reg <= 1'b1;
                    scheduler_state <= WAIT;
                end
                
                WAIT: begin
                    pe_valid_reg <= 1'b0;
                    if (pe_array_ready) begin
                        if (current_pe < PE_ROWS*PE_COLS - 1) begin
                            current_pe <= current_pe + 1'b1;
                            scheduler_state <= DISPATCH;
                        end else if (iteration_count > 0) begin
                            current_pe <= 5'd0;
                            iteration_count <= iteration_count - 1'b1;
                            scheduler_state <= DISPATCH;
                        end else begin
                            scheduler_state <= COMPLETE;
                        end
                    end
                end
                
                COMPLETE: begin
                    scheduler_state <= IDLE;
                end
                
                default: scheduler_state <= IDLE;
            endcase
        end
    end

endmodule
