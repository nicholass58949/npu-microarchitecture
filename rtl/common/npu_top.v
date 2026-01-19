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

    wire [31:0] scheduler_cmd;
    wire scheduler_valid;
    wire scheduler_ready;
    
    wire [31:0] decoded_cmd;
    wire [2:0] opcode;
    wire [ADDR_WIDTH-1:0] src_addr;
    wire [ADDR_WIDTH-1:0] dst_addr;
    wire [31:0] param1;
    wire [31:0] param2;
    wire decode_valid;
    wire decode_ready;
    
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
    wire dma_busy;
    
    wire [DATA_WIDTH-1:0] pe_array_input [PE_ROWS*PE_COLS-1:0];
    wire [DATA_WIDTH-1:0] pe_array_output [PE_ROWS*PE_COLS-1:0];
    wire pe_array_valid;
    wire pe_array_ready;
    wire pe_array_done;
    
    wire [DATA_WIDTH-1:0] noc_data_in [PE_ROWS*PE_COLS-1:0];
    wire [DATA_WIDTH-1:0] noc_data_out [PE_ROWS*PE_COLS-1:0];
    wire noc_valid_in [PE_ROWS*PE_COLS-1:0];
    wire noc_valid_out [PE_ROWS*PE_COLS-1:0];
    wire noc_ready_in [PE_ROWS*PE_COLS-1:0];
    wire noc_ready_out [PE_ROWS*PE_COLS-1:0];
    
    wire [DATA_WIDTH-1:0] conv_input;
    wire [DATA_WIDTH-1:0] conv_output;
    wire conv_valid;
    wire conv_ready;
    
    wire [DATA_WIDTH-1:0] matmul_input;
    wire [DATA_WIDTH-1:0] matmul_output;
    wire matmul_valid;
    wire matmul_ready;
    
    wire [DATA_WIDTH-1:0] pool_input;
    wire [DATA_WIDTH-1:0] pool_output;
    wire [2:0] pool_type;
    wire pool_valid;
    wire pool_ready;
    
    wire [DATA_WIDTH-1:0] activation_input;
    wire [DATA_WIDTH-1:0] activation_output;
    wire [1:0] activation_type;
    wire activation_valid;
    wire activation_ready;
    
    wire [DATA_WIDTH-1:0] bn_input;
    wire [DATA_WIDTH-1:0] bn_output;
    wire bn_valid;
    wire bn_ready;
    
    wire [DATA_WIDTH-1:0] softmax_input;
    wire [DATA_WIDTH-1:0] softmax_output;
    wire softmax_valid;
    wire softmax_ready;
    
    wire [DATA_WIDTH-1:0] elementwise_input_a;
    wire [DATA_WIDTH-1:0] elementwise_input_b;
    wire [DATA_WIDTH-1:0] elementwise_output;
    wire [2:0] elementwise_op;
    wire elementwise_valid;
    wire elementwise_ready;
    
    wire [DATA_WIDTH-1:0] concat_input_a;
    wire [DATA_WIDTH-1:0] concat_input_b;
    wire [DATA_WIDTH-1:0] concat_output;
    wire concat_valid;
    wire concat_ready;
    
    wire [DATA_WIDTH-1:0] reshape_input;
    wire [DATA_WIDTH-1:0] reshape_output;
    wire reshape_valid;
    wire reshape_ready;
    
    wire [DATA_WIDTH-1:0] transpose_input;
    wire [DATA_WIDTH-1:0] transpose_output;
    wire transpose_valid;
    wire transpose_ready;
    
    wire [DATA_WIDTH-1:0] reduction_input;
    wire [DATA_WIDTH-1:0] reduction_output;
    wire [2:0] reduction_op;
    wire reduction_valid;
    wire reduction_ready;
    
    wire [DATA_WIDTH-1:0] broadcast_input;
    wire [DATA_WIDTH-1:0] broadcast_output;
    wire broadcast_valid;
    wire broadcast_ready;
    
    wire [DATA_WIDTH-1:0] slice_input;
    wire [DATA_WIDTH-1:0] slice_output;
    wire slice_valid;
    wire slice_ready;
    
    wire [DATA_WIDTH-1:0] tile_input;
    wire [DATA_WIDTH-1:0] tile_output;
    wire tile_valid;
    wire tile_ready;
    
    wire [DATA_WIDTH-1:0] pad_input;
    wire [DATA_WIDTH-1:0] pad_output;
    wire pad_valid;
    wire pad_ready;
    
    wire [DATA_WIDTH-1:0] quant_input;
    wire [DATA_WIDTH-1:0] quant_output;
    wire quant_valid;
    wire quant_ready;
    
    wire [DATA_WIDTH-1:0] dequant_input;
    wire [DATA_WIDTH-1:0] dequant_output;
    wire dequant_valid;
    wire dequant_ready;
    
    wire [DATA_WIDTH-1:0] rearrange_input;
    wire [DATA_WIDTH-1:0] rearrange_output;
    wire rearrange_valid;
    wire rearrange_ready;
    
    wire [31:0] task_id;
    wire task_start;
    wire task_done;
    wire task_valid;
    wire task_ready;
    
    wire barrier_sync;
    wire barrier_done;
    wire barrier_valid;
    wire barrier_ready;
    
    wire [7:0] pe_load [PE_ROWS*PE_COLS-1:0];
    wire load_balance_en;
    wire [4:0] target_pe;
    
    wire perf_counter_en;
    wire [31:0] cycle_count;
    wire [31:0] op_count;
    
    wire [31:0] config_data;
    wire config_valid;
    wire config_ready;
    wire [7:0] config_addr;
    
    wire clock_gating_en;
    wire power_gating_en;
    
    wire [31:0] current_status;
    wire [7:0] interrupt_id;
    wire interrupt_req;
    wire interrupt_ack;

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

    instruction_decoder u_instruction_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .cmd(scheduler_cmd),
        .cmd_valid(scheduler_valid),
        .cmd_ready(scheduler_ready),
        .decoded_cmd(decoded_cmd),
        .opcode(opcode),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .param1(param1),
        .param2(param2),
        .decode_valid(decode_valid),
        .decode_ready(decode_ready)
    );

    task_manager u_task_manager (
        .clk(clk),
        .rst_n(rst_n),
        .decoded_cmd(decoded_cmd),
        .decode_valid(decode_valid),
        .decode_ready(decode_ready),
        .task_id(task_id),
        .task_start(task_start),
        .task_done(task_done),
        .task_valid(task_valid),
        .task_ready(task_ready)
    );

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
        .conv_valid(conv_valid),
        .conv_ready(conv_ready),
        .matmul_valid(matmul_valid),
        .matmul_ready(matmul_ready),
        .pool_valid(pool_valid),
        .pool_ready(pool_ready),
        .activation_valid(activation_valid),
        .activation_ready(activation_ready),
        .bn_valid(bn_valid),
        .bn_ready(bn_ready),
        .softmax_valid(softmax_valid),
        .softmax_ready(softmax_ready),
        .elementwise_valid(elementwise_valid),
        .elementwise_ready(elementwise_ready),
        .concat_valid(concat_valid),
        .concat_ready(concat_ready),
        .reshape_valid(reshape_valid),
        .reshape_ready(reshape_ready),
        .transpose_valid(transpose_valid),
        .transpose_ready(transpose_ready),
        .reduction_valid(reduction_valid),
        .reduction_ready(reduction_ready),
        .broadcast_valid(broadcast_valid),
        .broadcast_ready(broadcast_ready),
        .slice_valid(slice_valid),
        .slice_ready(slice_ready),
        .tile_valid(tile_valid),
        .tile_ready(tile_ready),
        .pad_valid(pad_valid),
        .pad_ready(pad_ready),
        .quant_valid(quant_valid),
        .quant_ready(quant_ready),
        .dequant_valid(dequant_valid),
        .dequant_ready(dequant_ready),
        .rearrange_valid(rearrange_valid),
        .rearrange_ready(rearrange_ready),
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
        .buffer_wdata(dma_wdata),
        .buffer_addr(dma_addr),
        .buffer_we(dma_we),
        .buffer_ce(dma_ce),
        .buffer_rdata(dma_rdata),
        .dma_done(dma_done),
        .dma_busy(dma_busy)
    );

    pe_array u_pe_array (
        .clk(clk),
        .rst_n(rst_n),
        .pe_input(pe_array_input),
        .pe_output(pe_array_output),
        .pe_valid(pe_array_valid),
        .pe_ready(pe_array_ready),
        .pe_done(pe_array_done),
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

    conv_engine u_conv_engine (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(conv_input),
        .output_data(conv_output),
        .valid(conv_valid),
        .ready(conv_ready)
    );

    matmul_engine u_matmul_engine (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(matmul_input),
        .output_data(matmul_output),
        .valid(matmul_valid),
        .ready(matmul_ready)
    );

    pooling_unit u_pooling_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(pool_input),
        .output_data(pool_output),
        .pool_type(pool_type),
        .valid(pool_valid),
        .ready(pool_ready)
    );

    activation_unit u_activation_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(activation_input),
        .output_data(activation_output),
        .activation_type(activation_type),
        .valid(activation_valid),
        .ready(activation_ready)
    );

    batch_normalization u_batch_normalization (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(bn_input),
        .output_data(bn_output),
        .valid(bn_valid),
        .ready(bn_ready)
    );

    softmax_unit u_softmax_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(softmax_input),
        .output_data(softmax_output),
        .valid(softmax_valid),
        .ready(softmax_ready)
    );

    element_wise_op u_element_wise_op (
        .clk(clk),
        .rst_n(rst_n),
        .input_a(elementwise_input_a),
        .input_b(elementwise_input_b),
        .output_data(elementwise_output),
        .op_type(elementwise_op),
        .valid(elementwise_valid),
        .ready(elementwise_ready)
    );

    concat_unit u_concat_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_a(concat_input_a),
        .input_b(concat_input_b),
        .output_data(concat_output),
        .valid(concat_valid),
        .ready(concat_ready)
    );

    reshape_unit u_reshape_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(reshape_input),
        .output_data(reshape_output),
        .valid(reshape_valid),
        .ready(reshape_ready)
    );

    transpose_unit u_transpose_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(transpose_input),
        .output_data(transpose_output),
        .valid(transpose_valid),
        .ready(transpose_ready)
    );

    reduction_unit u_reduction_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(reduction_input),
        .output_data(reduction_output),
        .reduction_op(reduction_op),
        .valid(reduction_valid),
        .ready(reduction_ready)
    );

    broadcast_unit u_broadcast_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(broadcast_input),
        .output_data(broadcast_output),
        .valid(broadcast_valid),
        .ready(broadcast_ready)
    );

    slice_unit u_slice_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(slice_input),
        .output_data(slice_output),
        .valid(slice_valid),
        .ready(slice_ready)
    );

    tile_unit u_tile_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(tile_input),
        .output_data(tile_output),
        .valid(tile_valid),
        .ready(tile_ready)
    );

    pad_unit u_pad_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(pad_input),
        .output_data(pad_output),
        .valid(pad_valid),
        .ready(pad_ready)
    );

    quantization_unit u_quantization_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(quant_input),
        .output_data(quant_output),
        .valid(quant_valid),
        .ready(quant_ready)
    );

    dequantization_unit u_dequantization_unit (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(dequant_input),
        .output_data(dequant_output),
        .valid(dequant_valid),
        .ready(dequant_ready)
    );

    data_rearrange u_data_rearrange (
        .clk(clk),
        .rst_n(rst_n),
        .input_data(rearrange_input),
        .output_data(rearrange_output),
        .valid(rearrange_valid),
        .ready(rearrange_ready)
    );

    barrier_synchronizer u_barrier_synchronizer (
        .clk(clk),
        .rst_n(rst_n),
        .sync_req(barrier_sync),
        .sync_done(barrier_done),
        .sync_valid(barrier_valid),
        .sync_ready(barrier_ready)
    );

    load_balancer u_load_balancer (
        .clk(clk),
        .rst_n(rst_n),
        .pe_load(pe_load),
        .load_balance_en(load_balance_en),
        .target_pe(target_pe)
    );

    performance_counter u_performance_counter (
        .clk(clk),
        .rst_n(rst_n),
        .enable(perf_counter_en),
        .cycle_count(cycle_count),
        .op_count(op_count)
    );

    config_register u_config_register (
        .clk(clk),
        .rst_n(rst_n),
        .config_data(config_data),
        .config_valid(config_valid),
        .config_ready(config_ready),
        .config_addr(config_addr)
    );

    clock_gating u_clock_gating (
        .clk(clk),
        .rst_n(rst_n),
        .enable(clock_gating_en),
        .gated_clk()
    );

    power_gating u_power_gating (
        .clk(clk),
        .rst_n(rst_n),
        .enable(power_gating_en),
        .power_down()
    );

    interrupt_controller u_interrupt_controller (
        .clk(clk),
        .rst_n(rst_n),
        .interrupt_req(interrupt_req),
        .interrupt_ack(interrupt_ack),
        .interrupt_id(interrupt_id),
        .interrupt(interrupt)
    );

    assign status = current_status;

endmodule
