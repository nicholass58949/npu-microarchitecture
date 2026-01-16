`include "../common/npu_definitions.vh"

module interrupt_controller (
    input wire clk,
    input wire rst_n,
    
    input wire [7:0] irq_lines,
    output wire [7:0] irq_mask,
    output wire irq_output,
    
    input wire [2:0] irq_ack,
    output wire [2:0] irq_id
);

    reg [7:0] irq_mask_reg;
    reg irq_output_reg;
    reg [2:0] irq_id_reg;
    reg [7:0] pending_irq;

    assign irq_mask = irq_mask_reg;
    assign irq_output = irq_output_reg;
    assign irq_id = irq_id_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            irq_mask_reg <= 8'd0;
            irq_output_reg <= 1'b0;
            irq_id_reg <= 3'd0;
            pending_irq <= 8'd0;
        end else begin
            pending_irq <= irq_lines & ~irq_mask_reg;
            
            if (pending_irq != 8'd0 && !irq_output_reg) begin
                irq_output_reg <= 1'b1;
                case (1'b1)
                    pending_irq[0]: irq_id_reg <= 3'd0;
                    pending_irq[1]: irq_id_reg <= 3'd1;
                    pending_irq[2]: irq_id_reg <= 3'd2;
                    pending_irq[3]: irq_id_reg <= 3'd3;
                    pending_irq[4]: irq_id_reg <= 3'd4;
                    pending_irq[5]: irq_id_reg <= 3'd5;
                    pending_irq[6]: irq_id_reg <= 3'd6;
                    pending_irq[7]: irq_id_reg <= 3'd7;
                    default: irq_id_reg <= 3'd0;
                endcase
            end
            
            if (irq_ack == irq_id_reg) begin
                irq_output_reg <= 1'b0;
            end
        end
    end

endmodule
