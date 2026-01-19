`include "../common/npu_definitions.vh"

module npu_top (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,
    
    output wire [15:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast,
    
    input wire [31:0] dram_addr,
    input wire [15:0] dram_wdata,
    output wire [15:0] dram_rdata,
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
    wire [31:0] src_addr;
    wire [31:0] dst_addr;
    wire [31:0] param1;
    wire [31:0] param2;
    wire decode_valid;
    wire decode_ready;
    
    wire [15:0] global_buffer_wdata;
    wire [31:0] global_buffer_addr;
    wire global_buffer_we;
    wire global_buffer_ce;
    wire [15:0] global_buffer_rdata;
    
    wire [15:0] dma_wdata;
    wire [31:0] dma_addr;
    wire dma_we;
    wire dma_ce;
    wire [15:0] dma_rdata;
    wire dma_done;
    wire dma_busy;
    
    wire [15:0] pe_array_input [0:63];
    wire [15:0] pe_array_output [0:63];
    wire pe_array_valid;
    wire pe_array_ready;
    wire pe_array_done;
    
    wire [15:0] noc_data_in [0:63];
    wire [15:0] noc_data_out [0:63];
    wire noc_valid_in [0:63];
    wire noc_valid_out [0:63];
    wire noc_ready_in [0:63];
    wire noc_ready_out [0:63];
    
    wire [15:0] conv_input [0:63];
    wire [15:0] conv_weight [0:63];
    wire [15:0] conv_output;
    wire conv_valid;
    wire conv_ready;
    wire conv_valid_out;
    wire conv_ready_out;
    
    wire [15:0] matmul_input [0:63];
    wire [15:0] matmul_weight [0:63];
    wire [15:0] matmul_output [0:63];
    wire matmul_valid;
    wire matmul_ready;
    wire matmul_valid_out;
    wire matmul_ready_out;
    
    wire [15:0] pool_input [0:3];
    wire [15:0] pool_output;
    wire [1:0] pool_type;
    wire pool_valid;
    wire pool_ready;
    wire pool_valid_out;
    wire pool_ready_out;
    
    wire [15:0] activation_input;
    wire [15:0] activation_output;
    wire [1:0] activation_type;
    wire activation_valid;
    wire activation_ready;
    wire activation_valid_out;
    wire activation_ready_out;
    
    wire [15:0] bn_input;
    wire [15:0] bn_output;
    wire bn_valid;
    wire bn_ready;
    wire bn_valid_out;
    wire bn_ready_out;
    
    wire [15:0] softmax_input [0:7];
    wire [15:0] softmax_output [0:7];
    wire softmax_valid;
    wire softmax_ready;
    wire softmax_valid_out;
    wire softmax_ready_out;
    
    wire [15:0] elementwise_input_a;
    wire [15:0] elementwise_input_b;
    wire [15:0] elementwise_output;
    wire [2:0] elementwise_op;
    wire elementwise_valid;
    wire elementwise_ready;
    wire elementwise_valid_out;
    wire elementwise_ready_out;
    
    wire [15:0] concat_input_a;
    wire [15:0] concat_input_b;
    wire [31:0] concat_output;
    wire concat_valid;
    wire concat_ready;
    wire concat_valid_out;
    wire concat_ready_out;
    
    wire [15:0] reshape_input [0:63];
    wire [15:0] reshape_output [0:63];
    wire reshape_valid;
    wire reshape_ready;
    wire reshape_valid_out;
    wire reshape_ready_out;
    wire [5:0] reshape_input_shape [0:3];
    wire [5:0] reshape_output_shape [0:3];
    
    wire [15:0] transpose_input [0:63];
    wire [15:0] transpose_output [0:63];
    wire transpose_valid;
    wire transpose_ready;
    wire transpose_valid_out;
    wire transpose_ready_out;
    
    wire [15:0] reduction_input [0:15];
    wire [15:0] reduction_output;
    wire [2:0] reduction_op;
    wire reduction_valid;
    wire reduction_ready;
    wire reduction_valid_out;
    wire reduction_ready_out;
    
    wire [15:0] broadcast_input;
    wire [15:0] broadcast_output [0:15];
    wire broadcast_valid;
    wire broadcast_ready;
    wire broadcast_valid_out;
    wire broadcast_ready_out;
    
    wire [15:0] slice_input [0:63];
    wire [15:0] slice_output [0:15];
    wire slice_valid;
    wire slice_ready;
    wire slice_valid_out;
    wire slice_ready_out;
    
    wire [15:0] tile_input [0:63];
    wire [15:0] tile_output [0:255];
    wire tile_valid;
    wire tile_ready;
    wire tile_valid_out;
    wire tile_ready_out;
    
    wire [15:0] pad_input [0:63];
    wire [15:0] pad_output [0:99];
    wire pad_valid;
    wire pad_ready;
    wire pad_valid_out;
    wire pad_ready_out;
    
    wire [15:0] quant_input;
    wire [15:0] quant_output;
    wire quant_valid;
    wire quant_ready;
    wire quant_valid_out;
    wire quant_ready_out;
    
    wire [15:0] dequant_input;
    wire [15:0] dequant_output;
    wire dequant_valid;
    wire dequant_ready;
    wire dequant_valid_out;
    wire dequant_ready_out;
    
    wire [15:0] rearrange_input [0:15];
    wire [15:0] rearrange_output [0:15];
    wire rearrange_valid;
    wire rearrange_ready;
    wire rearrange_valid_out;
    wire rearrange_ready_out;
    
    wire [31:0] task_id;
    wire task_start;
    wire task_done;
    wire task_valid;
    wire task_ready;
    
    wire barrier_sync;
    wire barrier_done;
    wire barrier_valid;
    wire barrier_ready;
    
    wire [7:0] pe_load [0:63];
    wire load_balance_en;
    wire [4:0] target_pe;
    
    wire perf_counter_en;
    wire [31:0] cycle_count;
    wire [31:0] op_count;
    
    wire [31:0] config_data;
    wire config_valid;
    wire config_ready;
    
    wire clock_gating_en;
    wire gated_clk;
    
    wire power_gating_en;
    wire power_good;
    
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
        .decoded_cmd(scheduler_cmd),
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
        .buffer_rdata(global_buffer_rdata),
        .dma_done(dma_done)
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
        .weight_data(conv_weight),
        .valid_in(conv_valid),
        .ready_in(conv_ready),
        .output_data(conv_output),
        .valid_out(conv_valid_out),
        .ready_out(conv_ready_out),
        .kernel_size(4'd3),
        .stride(4'd1),
        .padding(4'd0)
    );

    matmul_engine u_matmul_engine (
        .clk(clk),
        .rst_n(rst_n),
        .matrix_a(matmul_input),
        .matrix_b(matmul_weight),
        .valid_in(matmul_valid),
        .ready_in(matmul_ready),
        .output_data(matmul_output),
        .valid_out(matmul_valid_out),
        .ready_out(matmul_ready_out),
        .m_dim(4'd8),
        .n_dim(4'd8),
        .k_dim(4'd8)
    );

    pooling_unit u_pooling_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(pool_input),
        .data_out(pool_output),
        .pool_type(pool_type),
        .valid_in(pool_valid),
        .ready_in(pool_ready),
        .valid_out(pool_valid_out),
        .ready_out(pool_ready_out),
        .kernel_size(2'd2)
    );

    activation_unit u_activation_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in({24'd0, activation_input}),
        .data_out(activation_output),
        .act_type(activation_type),
        .valid(activation_valid),
        .valid_out(activation_valid_out)
    );

    batch_normalization u_batch_normalization (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(bn_input),
        .data_out(bn_output),
        .valid_in(bn_valid),
        .ready_in(bn_ready),
        .valid_out(bn_valid_out),
        .ready_out(bn_ready_out),
        .gamma(16'd1),
        .beta(16'd0),
        .mean(16'd0),
        .variance(16'd1)
    );

    softmax_unit u_softmax_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(softmax_input),
        .data_out(softmax_output),
        .valid_in(softmax_valid),
        .ready_in(softmax_ready),
        .valid_out(softmax_valid_out),
        .ready_out(softmax_ready_out)
    );

    element_wise_op u_element_wise_op (
        .clk(clk),
        .rst_n(rst_n),
        .operand_a(elementwise_input_a),
        .operand_b(elementwise_input_b),
        .data_out(elementwise_output),
        .op_type(elementwise_op),
        .valid_in(elementwise_valid),
        .ready_in(elementwise_ready),
        .valid_out(elementwise_valid_out),
        .ready_out(elementwise_ready_out)
    );

    concat_unit u_concat_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in_a(concat_input_a),
        .data_in_b(concat_input_b),
        .data_out(concat_output),
        .valid_in(concat_valid),
        .ready_in(concat_ready),
        .valid_out(concat_valid_out),
        .ready_out(concat_ready_out)
    );

    reshape_unit u_reshape_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(reshape_input),
        .data_out(reshape_output),
        .valid_in(reshape_valid),
        .ready_in(reshape_ready),
        .valid_out(reshape_valid_out),
        .ready_out(reshape_ready_out),
        .input_shape(reshape_input_shape),
        .output_shape(reshape_output_shape)
    );

    transpose_unit u_transpose_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(transpose_input),
        .data_out(transpose_output),
        .valid_in(transpose_valid),
        .ready_in(transpose_ready),
        .valid_out(transpose_valid_out),
        .ready_out(transpose_ready_out)
    );

    reduction_unit u_reduction_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(reduction_input),
        .data_out(reduction_output),
        .reduction_type(reduction_op),
        .valid_in(reduction_valid),
        .ready_in(reduction_ready),
        .valid_out(reduction_valid_out),
        .ready_out(reduction_ready_out)
    );

    broadcast_unit u_broadcast_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(broadcast_input),
        .data_out(broadcast_output),
        .valid_in(broadcast_valid),
        .ready_in(broadcast_ready),
        .valid_out(broadcast_valid_out),
        .ready_out(broadcast_ready_out)
    );

    slice_unit u_slice_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(slice_input),
        .data_out(slice_output),
        .valid_in(slice_valid),
        .ready_in(slice_ready),
        .valid_out(slice_valid_out),
        .ready_out(slice_ready_out),
        .start_idx(6'd0),
        .end_idx(6'd15)
    );

    tile_unit u_tile_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(tile_input),
        .data_out(tile_output),
        .valid_in(tile_valid),
        .ready_in(tile_ready),
        .valid_out(tile_valid_out),
        .ready_out(tile_ready_out),
        .repeat_factor(4'd4)
    );

    pad_unit u_pad_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(pad_input),
        .data_out(pad_output),
        .valid_in(pad_valid),
        .ready_in(pad_ready),
        .valid_out(pad_valid_out),
        .ready_out(pad_ready_out),
        .pad_top(4'd1),
        .pad_bottom(4'd1),
        .pad_left(4'd1),
        .pad_right(4'd1),
        .pad_value(16'd0)
    );

    quantization_unit u_quantization_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(quant_input),
        .data_out(quant_output),
        .valid_in(quant_valid),
        .ready_in(quant_ready),
        .valid_out(quant_valid_out),
        .ready_out(quant_ready_out),
        .scale(16'd1),
        .zero_point(16'd0),
        .input_bits(2'd1),
        .output_bits(2'd1)
    );

    dequantization_unit u_dequantization_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(dequant_input),
        .data_out(dequant_output),
        .valid_in(dequant_valid),
        .ready_in(dequant_ready),
        .valid_out(dequant_valid_out),
        .ready_out(dequant_ready_out),
        .scale(16'd1),
        .zero_point(16'd0)
    );

    data_rearrange u_data_rearrange (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(rearrange_input),
        .data_out(rearrange_output),
        .valid_in(rearrange_valid),
        .ready_in(rearrange_ready),
        .valid_out(rearrange_valid_out),
        .ready_out(rearrange_ready_out),
        .rearrange_mode(4'd0)
    );

    barrier_synchronizer u_barrier_synchronizer (
        .clk(clk),
        .rst_n(rst_n),
        .pe_id(4'd0),
        .pe_ready(barrier_sync),
        .pe_release(barrier_done),
        .barrier_count(4'd8),
        .barrier_enable(barrier_valid)
    );

    performance_counter u_performance_counter (
        .clk(clk),
        .rst_n(rst_n),
        .enable(perf_counter_en),
        .counter_select(4'd0),
        .counter_value(cycle_count)
    );

    config_register u_config_register (
        .clk(clk),
        .rst_n(rst_n),
        .config_data(config_data[15:0]),
        .config_valid(config_valid),
        .config_ready(config_ready)
    );

    clock_gating u_clock_gating (
        .clk(clk),
        .rst_n(rst_n),
        .enable(clock_gating_en),
        .gated_clk(gated_clk)
    );

    power_gating u_power_gating (
        .clk(clk),
        .rst_n(rst_n),
        .power_down(power_gating_en),
        .power_good(power_good)
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
