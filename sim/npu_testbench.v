`include "npu_definitions.vh"

module npu_testbench;

    reg clk;
    reg rst_n;
    
    reg [15:0] s_axis_tdata;
    reg s_axis_tvalid;
    wire s_axis_tready;
    reg s_axis_tlast;
    
    wire [15:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;
    wire m_axis_tlast;
    
    reg [31:0] dram_addr;
    reg [15:0] dram_wdata;
    wire [15:0] dram_rdata;
    reg dram_we;
    reg dram_ce;
    
    wire [31:0] status;
    wire interrupt;

    npu_top u_npu_top (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .dram_addr(dram_addr),
        .dram_wdata(dram_wdata),
        .dram_rdata(dram_rdata),
        .dram_we(dram_we),
        .dram_ce(dram_ce),
        .status(status),
        .interrupt(interrupt)
    );

    initial begin
        clk = 0;
        rst_n = 0;
        s_axis_tdata = 16'd0;
        s_axis_tvalid = 1'b0;
        m_axis_tready = 1'b1;
        dram_addr = 32'd0;
        dram_wdata = 16'd0;
        dram_we = 1'b0;
        dram_ce = 1'b0;
        
        #100;
        rst_n = 1;
        
        #100;
        
        repeat (10) begin
            @(posedge clk);
            s_axis_tvalid = 1'b1;
            s_axis_tdata = $random;
            @(posedge clk);
            s_axis_tvalid = 1'b0;
            #20;
        end
        
        #1000;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
