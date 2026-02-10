`include "../common/npu_definitions.vh"

// Simplified NPU Top Level Module
// Focuses on core computation with PE array and basic data flow

module npu_top (
    input wire clk,
    input wire rst_n,
    
    // AXI-Stream Slave interface (Input)
    input wire [15:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,
    
    // AXI-Stream Master interface (Output)
    output wire [15:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast,
    
    // DRAM Interface
    input wire [31:0] dram_addr,
    input wire [15:0] dram_wdata,
    output wire [15:0] dram_rdata,
    input wire dram_we,
    input wire dram_ce,
    output wire dram_ready,
    
    // Status and Interrupt
    output wire [31:0] status,
    output wire interrupt
);

    // ========== Internal Signals ==========
    
    // Host Interface to Instruction Decoder
    wire [31:0] scheduler_cmd;
    wire scheduler_valid;
    wire scheduler_ready;
    
    // Instruction Decoder to Scheduler
    wire [2:0] opcode;
    wire [31:0] src_addr;
    wire [31:0] dst_addr;
    wire [31:0] param1;
    wire [31:0] param2;
    wire decode_valid;
    wire decode_ready;
    
    // Task Manager signals
    wire [31:0] task_id;
    wire task_start;
    wire task_done;
    wire task_valid;
    wire task_ready;
    
    // Memory System
    wire [15:0] global_buffer_wdata;
    wire [31:0] global_buffer_addr;
    wire global_buffer_we;
    wire global_buffer_ce;
    wire [15:0] global_buffer_rdata;
    
    // DMA Interface
    wire [15:0] dma_wdata;
    wire [31:0] dma_addr;
    wire dma_we;
    wire dma_ce;
    wire [15:0] dma_rdata;
    wire dma_done;
    wire dma_busy;
    
    // PE Array Interface
    wire [15:0] pe_array_input [0:63];
    wire [15:0] pe_array_output [0:63];
    wire pe_array_valid;
    wire pe_array_ready;
    wire pe_array_done;
    
    // Status and Control
    wire [31:0] current_status;
    wire interrupt_req;
    wire interrupt_ack;
    wire [7:0] interrupt_id;

    // ========== Instantiate Host Interface ==========
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
        .status(current_status),
        .interrupt_req(interrupt_req),
        .interrupt_ack(interrupt_ack),
        .interrupt_id(interrupt_id)
    );

    // ========== Instantiate Instruction Decoder ==========
    instruction_decoder u_instruction_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .cmd(scheduler_cmd),
        .cmd_valid(scheduler_valid),
        .cmd_ready(scheduler_ready),
        .opcode(opcode),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .param1(param1),
        .param2(param2),
        .decode_valid(decode_valid),
        .decode_ready(decode_ready)
    );

    // ========== Instantiate Task Manager ==========
    task_manager u_task_manager (
        .clk(clk),
        .rst_n(rst_n),
        .decoded_cmd(scheduler_cmd),
        .decode_valid(decode_valid),
        .decode_ready(decode_ready),
        .task_id(task_id),
        .task_start(task_start),
        .task_done(task_done),
        .task_valid(task_valid),
        .task_ready(task_ready)
    );

    // ========== Instantiate Instruction Scheduler ==========
    instruction_scheduler u_instruction_scheduler (
        .clk(clk),
        .rst_n(rst_n),
        .task_id(task_id),
        .task_start(task_start),
        .task_valid(task_valid),
        .task_ready(task_ready),
        .opcode(opcode),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .param1(param1),
        .param2(param2),
        .pe_array_input(pe_array_input),
        .pe_array_output(pe_array_output),
        .pe_array_valid(pe_array_valid),
        .pe_array_ready(pe_array_ready),
        .pe_array_done(pe_array_done),
        .global_buffer_addr(global_buffer_addr),
        .global_buffer_wdata(global_buffer_wdata),
        .global_buffer_we(global_buffer_we),
        .global_buffer_ce(global_buffer_ce),
        .global_buffer_rdata(global_buffer_rdata),
        .dma_addr(dma_addr),
        .dma_wdata(dma_wdata),
        .dma_we(dma_we),
        .dma_ce(dma_ce),
        .dma_rdata(dma_rdata),
        .dma_done(dma_done),
        .dma_busy(dma_busy)
    );

    // ========== Instantiate Global Buffer (Local Memory) ==========
    global_buffer u_global_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .wdata(global_buffer_wdata),
        .addr(global_buffer_addr),
        .we(global_buffer_we),
        .ce(global_buffer_ce),
        .rdata(global_buffer_rdata)
    );

    // ========== Instantiate DMA Controller ==========
    dma_controller u_dma_controller (
        .clk(clk),
        .rst_n(rst_n),
        .dram_addr(dram_addr),
        .dram_wdata(dram_wdata),
        .dram_rdata(dram_rdata),
        .dram_we(dram_we),
        .dram_ce(dram_ce),
        .dram_ready(dram_ready),
        .buffer_wdata(dma_wdata),
        .buffer_addr(dma_addr),
        .buffer_we(dma_we),
        .buffer_ce(dma_ce),
        .buffer_rdata(global_buffer_rdata),
        .dma_done(dma_done)
    );

    // ========== Instantiate PE Array (Simplified 8x8) ==========
    pe_array u_pe_array (
        .clk(clk),
        .rst_n(rst_n),
        .pe_input(pe_array_input),
        .pe_output(pe_array_output),
        .pe_valid(pe_array_valid),
        .pe_ready(pe_array_ready),
        .pe_done(pe_array_done)
    );

    // ========== Instantiate Simplified Interrupt Controller ==========
    interrupt_controller u_interrupt_controller (
        .clk(clk),
        .rst_n(rst_n),
        .interrupt_req(interrupt_req),
        .interrupt_ack(interrupt_ack),
        .interrupt_id(interrupt_id),
        .interrupt(interrupt)
    );

    // ========== Status Assignment ==========
    assign status = current_status;

endmodule
