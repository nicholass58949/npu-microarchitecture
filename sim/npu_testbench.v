`include "../rtl/common/npu_definitions.vh"

module npu_testbench;

    reg clk;
    reg rst_n;
    
    reg [DATA_WIDTH-1:0] s_axis_tdata;
    reg s_axis_tvalid;
    wire s_axis_tready;
    reg s_axis_tlast;
    
    wire [DATA_WIDTH-1:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;
    wire m_axis_tlast;
    
    reg [ADDR_WIDTH-1:0] dram_addr;
    reg [DATA_WIDTH-1:0] dram_wdata;
    wire [DATA_WIDTH-1:0] dram_rdata;
    reg dram_we;
    reg dram_ce;
    wire dram_ready;
    
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
        .dram_ready(dram_ready),
        .status(status),
        .interrupt(interrupt)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        
        s_axis_tdata = 16'h0000;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        m_axis_tready = 1;
        dram_addr = 32'h0000_0000;
        dram_wdata = 16'h0000;
        dram_we = 0;
        dram_ce = 0;
        
        #100;
        
        s_axis_tdata = 16'h1234;
        s_axis_tvalid = 1;
        #10;
        s_axis_tvalid = 0;
        
        #100;
        
        s_axis_tdata = 16'h5678;
        s_axis_tvalid = 1;
        #10;
        s_axis_tvalid = 0;
        
        #1000;
        
        $finish;
    end

endmodule
