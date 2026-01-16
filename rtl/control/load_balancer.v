`include "../common/npu_definitions.vh"

module load_balancer (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] task_data,
    input wire task_valid,
    output reg task_ready,
    
    output wire [DATA_WIDTH-1:0] pe_task_data [PE_ROWS*PE_COLS-1:0],
    output wire pe_task_valid [PE_ROWS*PE_COLS-1:0],
    input wire pe_task_ready [PE_ROWS*PE_COLS-1:0]
);

    reg [DATA_WIDTH-1:0] pe_task_data_reg [PE_ROWS*PE_COLS-1:0];
    reg pe_task_valid_reg [PE_ROWS*PE_COLS-1:0];
    reg [3:0] pe_load_count [PE_ROWS*PE_COLS-1:0];
    reg [4:0] current_pe;
    reg [2:0] balancer_state;

    assign pe_task_data = pe_task_data_reg;
    assign pe_task_valid = pe_task_valid_reg;

    localparam IDLE = 3'd0;
    localparam SELECT_PE = 3'd1;
    localparam DISPATCH = 3'd2;
    localparam WAIT_ACK = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            task_ready <= 1'b1;
            current_pe <= 5'd0;
            balancer_state <= IDLE;
            
            for (integer i = 0; i < PE_ROWS*PE_COLS; i = i + 1) begin
                pe_task_data_reg[i] <= {DATA_WIDTH{1'b0}};
                pe_task_valid_reg[i] <= 1'b0;
                pe_load_count[i] <= 4'd0;
            end
        end else begin
            case (balancer_state)
                IDLE: begin
                    task_ready <= 1'b1;
                    if (task_valid && task_ready) begin
                        balancer_state <= SELECT_PE;
                    end
                end
                
                SELECT_PE: begin
                    task_ready <= 1'b0;
                    current_pe <= 5'd0;
                    balancer_state <= DISPATCH;
                end
                
                DISPATCH: begin
                    pe_task_data_reg[current_pe] <= task_data;
                    pe_task_valid_reg[current_pe] <= 1'b1;
                    pe_load_count[current_pe] <= pe_load_count[current_pe] + 1'b1;
                    balancer_state <= WAIT_ACK;
                end
                
                WAIT_ACK: begin
                    if (pe_task_ready[current_pe]) begin
                        pe_task_valid_reg[current_pe] <= 1'b0;
                        if (current_pe < PE_ROWS*PE_COLS - 1) begin
                            current_pe <= current_pe + 1'b1;
                            balancer_state <= DISPATCH;
                        end else begin
                            balancer_state <= IDLE;
                        end
                    end
                end
                
                default: balancer_state <= IDLE;
            endcase
        end
    end

endmodule
