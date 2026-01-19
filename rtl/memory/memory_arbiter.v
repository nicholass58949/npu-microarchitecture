`include "../common/npu_definitions.vh"

module memory_arbiter (
    input wire clk,
    input wire rst_n,
    
    input wire [31:0] req0_addr,
    input wire [15:0] req0_wdata,
    output wire [15:0] req0_rdata,
    input wire req0_we,
    input wire req0_ce,
    output wire req0_ready,
    
    input wire [31:0] req1_addr,
    input wire [15:0] req1_wdata,
    output wire [15:0] req1_rdata,
    input wire req1_we,
    input wire req1_ce,
    output wire req1_ready,
    
    output wire [31:0] mem_addr,
    output wire [15:0] mem_wdata,
    input wire [15:0] mem_rdata,
    output wire mem_we,
    output wire mem_ce
);

    reg [15:0] req0_rdata_reg, req1_rdata_reg;
    reg req0_ready_reg, req1_ready_reg;
    reg [31:0] mem_addr_reg;
    reg [15:0] mem_wdata_reg;
    reg mem_we_reg, mem_ce_reg;
    reg arbiter_select;

    assign req0_rdata = req0_rdata_reg;
    assign req1_rdata = req1_rdata_reg;
    assign req0_ready = req0_ready_reg;
    assign req1_ready = req1_ready_reg;
    assign mem_addr = mem_addr_reg;
    assign mem_wdata = mem_wdata_reg;
    assign mem_we = mem_we_reg;
    assign mem_ce = mem_ce_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req0_ready_reg <= 1'b1;
            req1_ready_reg <= 1'b1;
            mem_addr_reg <= {32{1'b0}};
            mem_wdata_reg <= {16{1'b0}};
            mem_we_reg <= 1'b0;
            mem_ce_reg <= 1'b0;
            arbiter_select <= 1'b0;
        end else begin
            if (req0_ce && !req1_ce) begin
                mem_addr_reg <= req0_addr;
                mem_wdata_reg <= req0_wdata;
                mem_we_reg <= req0_we;
                mem_ce_reg <= 1'b1;
                req0_ready_reg <= 1'b0;
                req1_ready_reg <= 1'b0;
                req0_rdata_reg <= mem_rdata;
                arbiter_select <= 1'b0;
            end else if (!req0_ce && req1_ce) begin
                mem_addr_reg <= req1_addr;
                mem_wdata_reg <= req1_wdata;
                mem_we_reg <= req1_we;
                mem_ce_reg <= 1'b1;
                req0_ready_reg <= 1'b0;
                req1_ready_reg <= 1'b0;
                req1_rdata_reg <= mem_rdata;
                arbiter_select <= 1'b1;
            end else if (req0_ce && req1_ce) begin
                if (arbiter_select == 1'b0) begin
                    mem_addr_reg <= req0_addr;
                    mem_wdata_reg <= req0_wdata;
                    mem_we_reg <= req0_we;
                    mem_ce_reg <= 1'b1;
                    req0_ready_reg <= 1'b0;
                    req1_ready_reg <= 1'b0;
                    req0_rdata_reg <= mem_rdata;
                    arbiter_select <= 1'b1;
                end else begin
                    mem_addr_reg <= req1_addr;
                    mem_wdata_reg <= req1_wdata;
                    mem_we_reg <= req1_we;
                    mem_ce_reg <= 1'b1;
                    req0_ready_reg <= 1'b0;
                    req1_ready_reg <= 1'b0;
                    req1_rdata_reg <= mem_rdata;
                    arbiter_select <= 1'b0;
                end
            end else begin
                mem_ce_reg <= 1'b0;
                req0_ready_reg <= 1'b1;
                req1_ready_reg <= 1'b1;
            end
        end
    end

endmodule
