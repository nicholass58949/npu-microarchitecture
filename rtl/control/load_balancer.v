`include "../common/npu_definitions.vh"

module load_balancer (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] task_data,
    input wire task_valid,
    output reg task_ready,
    
    output wire [15:0] pe_task_data [0:63],
    output wire pe_task_valid [0:63],
    input wire pe_task_ready [0:63]
);

    reg [15:0] pe_task_data_reg [0:63];
    reg pe_task_valid_reg [0:63];
    reg [3:0] pe_load_count [0:63];
    reg [5:0] current_pe;
    reg [2:0] balancer_state;

    assign pe_task_data = pe_task_data_reg;
    assign pe_task_valid = pe_task_valid_reg;

    localparam IDLE = 3'd0;
    localparam SELECT_PE = 3'd1;
    localparam DISPATCH = 3'd2;
    localparam WAIT_ACK = 3'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            task_ready <= 1'b0;
            current_pe <= 6'd0;
            balancer_state <= IDLE;
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
                    current_pe <= current_pe + 1'b1;
                    if (current_pe == 6'd63) begin
                        current_pe <= 6'd0;
                    end
                    balancer_state <= DISPATCH;
                end
                
                DISPATCH: begin
                    pe_task_data_reg[current_pe] <= task_data;
                    pe_task_valid_reg[current_pe] <= 1'b1;
                    if (pe_task_ready[current_pe]) begin
                        pe_task_valid_reg[current_pe] <= 1'b0;
                        balancer_state <= IDLE;
                    end
                end
                
                default: balancer_state <= IDLE;
            endcase
        end
    end

endmodule
