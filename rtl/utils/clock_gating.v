`include "../common/npu_definitions.vh"

module clock_gating (
    input wire clk,
    input wire rst_n,
    input wire enable,
    output wire gated_clk
);

    reg latch_enable;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latch_enable <= 1'b0;
        end else begin
            latch_enable <= enable;
        end
    end

    assign gated_clk = clk & latch_enable;

endmodule
