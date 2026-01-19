`include "../common/npu_definitions.vh"

module global_buffer (
    input wire clk,
    input wire rst_n,
    input wire [15:0] wdata,
    input wire [31:0] addr,
    input wire we,
    input wire ce,
    output reg [15:0] rdata
);

    reg [15:0] memory [0:1024-1];
    reg [15:0] rdata_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata_reg <= {16{1'b0}};
        end else if (ce && !we) begin
            rdata_reg <= memory[addr[32-1:0]];
        end
    end

    always @(posedge clk) begin
        if (ce && we) begin
            memory[addr[32-1:0]] <= wdata;
        end
    end

    assign rdata = rdata_reg;

endmodule
