`include "../common/npu_definitions.vh"

module npu_top (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,
    
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast,
    
    input wire [ADDR_WIDTH-1:0] dram_addr,
    input wire [DATA_WIDTH-1:0] dram_wdata,
    output wire [DATA_WIDTH-1:0] dram_rdata,
    input wire dram_we,
    input wire dram_ce,
    output wire dram_ready,
    
    output wire [31:0] status,
    output wire interrupt
);

    wire [DATA_WIDTH-1:0] global_buffer_wdata;
    wire [ADDR_WIDTH-1:0] global_buffer_addr;
    wire global_buffer_we;
    wire global_buffer_ce;
    wire [DATA_WIDTH-1:0] global_buffer_rdata;
    
    wire [DATA_WIDTH-1:0] dma_wdata;
    wire [ADDR_WIDTH-1:0] dma_addr;
    wire dma_we;
    wire dma_ce;
    wire [DATA_WIDTH-1:0] dma_rdata;
    wire dma_done;
    
    wire [DATA_WIDTH-1:0] pe_array_input [PE_ROWS*PE_COLS-1:0];
    wire [DATA_WIDTH-1:0] pe_array_output [PE_ROWS*PE_COLS-1:0];
    wire pe_array_valid;
    wire pe_array_ready;
    
    wire [31:0] scheduler_cmd;
    wire scheduler_valid;
    wire scheduler_ready;
    
    wire [DATA_WIDTH-1:0] noc_data_in [PE_ROWS*PE_COLS-1:0];
    wire [DATA_WIDTH-1:0] noc_data_out [PE_ROWS*PE_COLS-1:0];
    wire noc_valid_in [PE_ROWS*PE_COLS-1:0];
    wire noc_valid_out [PE_ROWS*PE_COLS-1:0];
    wire noc_ready_in [PE_ROWS*PE_COLS-1:0];
    wire noc_ready_out [PE_ROWS*PE_COLS-1:0];

    host_interface u_host_interface (
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
        .scheduler_cmd(scheduler_cmd),
        .scheduler_valid(scheduler_valid),
        .scheduler_ready(scheduler_ready),
        .status(status),
        .interrupt(interrupt)
    );

    global_buffer u_global_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .wdata(global_buffer_wdata),
        .addr(global_buffer_addr),
        .we(global_buffer_we),
        .ce(global_buffer_ce),
        .rdata(global_buffer_rdata)
    );

    dma_controller u_dma_controller (
        .clk(clk),
        .rst_n(rst_n),
        .dram_addr(dram_addr),
        .dram_wdata(dram_wdata),
        .dram_rdata(dram_rdata),
        .dram_we(dram_we),
        .dram_ce(dram_ce),
        .dram_ready(dram_ready),
        .buffer_wdata(global_buffer_wdata),
        .buffer_addr(global_buffer_addr),
        .buffer_we(global_buffer_we),
        .buffer_ce(global_buffer_ce),
        .buffer_rdata(global_buffer_rdata),
        .dma_done(dma_done)
    );

    instruction_scheduler u_instruction_scheduler (
        .clk(clk),
        .rst_n(rst_n),
        .cmd(scheduler_cmd),
        .cmd_valid(scheduler_valid),
        .cmd_ready(scheduler_ready),
        .pe_array_input(pe_array_input),
        .pe_array_output(pe_array_output),
        .pe_array_valid(pe_array_valid),
        .pe_array_ready(pe_array_ready)
    );

    pe_array u_pe_array (
        .clk(clk),
        .rst_n(rst_n),
        .pe_input(pe_array_input),
        .pe_output(pe_array_output),
        .pe_valid(pe_array_valid),
        .pe_ready(pe_array_ready),
        .noc_data_in(noc_data_in),
        .noc_data_out(noc_data_out),
        .noc_valid_in(noc_valid_in),
        .noc_valid_out(noc_valid_out),
        .noc_ready_in(noc_ready_in),
        .noc_ready_out(noc_ready_out)
    );

    network_on_chip u_network_on_chip (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(noc_data_out),
        .data_out(noc_data_in),
        .valid_in(noc_valid_out),
        .valid_out(noc_valid_in),
        .ready_in(noc_ready_out),
        .ready_out(noc_ready_in)
    );

endmodule
