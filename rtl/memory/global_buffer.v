`include "../common/npu_definitions.vh"

module global_buffer (
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire we,
    input wire ce,
    output reg [DATA_WIDTH-1:0] rdata
);

    reg [DATA_WIDTH-1:0] memory [0:BUFFER_SIZE-1];
    reg [DATA_WIDTH-1:0] rdata_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata_reg <= {DATA_WIDTH{1'b0}};
        end else if (ce && !we) begin
            rdata_reg <= memory[addr[ADDR_WIDTH-1:0]];
        end
    end

    always @(posedge clk) begin
        if (ce && we) begin
            memory[addr[ADDR_WIDTH-1:0]] <= wdata;
        end
    end

    assign rdata = rdata_reg;

endmodule
