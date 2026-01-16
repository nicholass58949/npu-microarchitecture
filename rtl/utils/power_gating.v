`include "../common/npu_definitions.vh"

module power_gating (
    input wire clk,
    input wire rst_n,
    input wire power_down,
    output wire power_good
);

    reg [7:0] power_state;
    reg power_good_reg;

    assign power_good = power_good_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            power_state <= 8'd0;
            power_good_reg <= 1'b0;
        end else begin
            if (power_down) begin
                if (power_state < 8'd255) begin
                    power_state <= power_state + 1'b1;
                end else begin
                    power_good_reg <= 1'b0;
                end
            end else begin
                if (power_state > 8'd0) begin
                    power_state <= power_state - 1'b1;
                end else begin
                    power_good_reg <= 1'b1;
                end
            end
        end
    end

endmodule
