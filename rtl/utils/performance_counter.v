`include "../common/npu_definitions.vh"

module performance_counter (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [3:0] counter_select,
    output wire [31:0] counter_value
);

    reg [31:0] cycle_count;
    reg [31:0] instruction_count;
    reg [31:0] mac_count;
    reg [31:0] memory_access_count;
    reg [31:0] stall_count;

    assign counter_value = (counter_select == 4'd0) ? cycle_count :
                           (counter_select == 4'd1) ? instruction_count :
                           (counter_select == 4'd2) ? mac_count :
                           (counter_select == 4'd3) ? memory_access_count :
                           (counter_select == 4'd4) ? stall_count :
                           32'd0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count <= 32'd0;
            instruction_count <= 32'd0;
            mac_count <= 32'd0;
            memory_access_count <= 32'd0;
            stall_count <= 32'd0;
        end else if (enable) begin
            cycle_count <= cycle_count + 1'b1;
        end
    end

endmodule
