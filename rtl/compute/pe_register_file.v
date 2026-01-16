`include "../common/npu_definitions.vh"

module pe_register_file (
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [3:0] waddr,
    input wire we,
    input wire [3:0] raddr_a,
    input wire [3:0] raddr_b,
    output reg [DATA_WIDTH-1:0] rdata_a,
    output reg [DATA_WIDTH-1:0] rdata_b
);

    reg [DATA_WIDTH-1:0] reg_file [0:15];

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 16; i = i + 1) begin
                reg_file[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (we) begin
            reg_file[waddr] <= wdata;
        end
    end

    always @(*) begin
        rdata_a = reg_file[raddr_a];
        rdata_b = reg_file[raddr_b];
    end

endmodule
