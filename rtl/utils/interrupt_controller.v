`include "../common/npu_definitions.vh"

module interrupt_controller (
    input wire clk,
    input wire rst_n,
    
    input wire interrupt_req,
    output wire interrupt_ack,
    input wire [7:0] interrupt_id,
    output wire interrupt
);

    reg interrupt_ack_reg;
    reg interrupt_reg;
    reg [7:0] interrupt_id_reg;

    assign interrupt_ack = interrupt_ack_reg;
    assign interrupt = interrupt_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            interrupt_ack_reg <= 1'b0;
            interrupt_reg <= 1'b0;
            interrupt_id_reg <= 8'd0;
        end else begin
            if (interrupt_req && !interrupt_ack_reg) begin
                interrupt_ack_reg <= 1'b1;
                interrupt_reg <= 1'b1;
                interrupt_id_reg <= interrupt_id;
            end
            
            if (interrupt_ack_reg) begin
                interrupt_ack_reg <= 1'b0;
                interrupt_reg <= 1'b0;
            end
        end
    end

endmodule
