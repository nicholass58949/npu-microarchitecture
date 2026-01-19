# NPU微架构设计文档

## 1. 整体架构概述

NPU（神经网络处理器）采用分层架构设计，从顶层到底层分为以下几个层次：

```
┌─────────────────────────────────────────────────────────────┐
│                     NPU Top Level                         │
├─────────────────────────────────────────────────────────────┤
│  Host Interface (AXI-Stream)                             │
│  └── Instruction Decoder                                 │
│      └── Task Manager                                     │
│          └── Instruction Scheduler                         │
├─────────────────────────────────────────────────────────────┤
│  Memory Subsystem                                        │
│  ├── Global Buffer                                       │
│  └── DMA Controller                                     │
├─────────────────────────────────────────────────────────────┤
│  Compute Subsystem                                       │
│  ├── PE Array (8x8)                                     │
│  ├── Conv Engine                                         │
│  └── Matmul Engine                                      │
├─────────────────────────────────────────────────────────────┤
│  Special Functions                                      │
│  ├── Pooling Unit                                        │
│  ├── Activation Unit                                     │
│  ├── Batch Normalization                                 │
│  └── Softmax Unit                                       │
├─────────────────────────────────────────────────────────────┤
│  Data Operations                                        │
│  ├── Element-wise Op                                     │
│  ├── Concat Unit                                         │
│  ├── Reshape Unit                                        │
│  ├── Transpose Unit                                      │
│  ├── Reduction Unit                                       │
│  ├── Broadcast Unit                                       │
│  ├── Slice Unit                                         │
│  ├── Tile Unit                                          │
│  └── Pad Unit                                           │
├─────────────────────────────────────────────────────────────┤
│  Utility Modules                                         │
│  ├── Quantization Unit                                   │
│  ├── Dequantization Unit                                 │
│  ├── Data Rearrange                                     │
│  ├── Zero Skipping                                       │
│  └── Sparse Compression                                  │
├─────────────────────────────────────────────────────────────┤
│  Control Subsystem                                       │
│  ├── Barrier Synchronizer                                │
│  ├── Load Balancer                                       │
│  ├── Performance Counter                                  │
│  ├── Config Register                                     │
│  ├── Clock Gating                                       │
│  └── Power Gating                                       │
├─────────────────────────────────────────────────────────────┤
│  Communication Subsystem                                 │
│  └── Network-on-Chip (Mesh Topology)                     │
└─────────────────────────────────────────────────────────────┘
```

## 2. 数据流和控制流

### 2.1 指令执行流程

```
1. Host Interface 接收外部指令
   ↓
2. Instruction Decoder 解码指令
   ↓
3. Task Manager 管理任务队列
   ↓
4. Instruction Scheduler 调度指令执行
   ↓
5. 根据操作码分发到相应模块
   ↓
6. 执行完成后返回结果
```

### 2.2 数据访问流程

```
外部 DRAM
   ↓
DMA Controller
   ↓
Global Buffer
   ↓
PE Array / Special Functions / Data Operations
   ↓
Global Buffer
   ↓
DMA Controller
   ↓
外部 DRAM
```

### 2.3 PE间通信流程

```
PE Array
   ↓
Network-on-Chip (Mesh Topology)
   ↓
PE Array (其他PE)
```

## 3. 模块连接关系

### 3.1 控制流连接

#### Host Interface → Instruction Decoder
```
Host Interface:
  - scheduler_cmd[31:0] → Instruction Decoder: cmd[31:0]
  - scheduler_valid → Instruction Decoder: cmd_valid
  - Instruction Decoder: cmd_ready → scheduler_ready
```

#### Instruction Decoder → Task Manager
```
Instruction Decoder:
  - decoded_cmd[31:0] → Task Manager: decoded_cmd[31:0]
  - decode_valid → Task Manager: decode_valid
  - Task Manager: decode_ready → decode_ready
```

#### Task Manager → Instruction Scheduler
```
Task Manager:
  - task_id[31:0] → Instruction Scheduler: task_id[31:0]
  - task_start → Instruction Scheduler: task_start
  - task_valid → Instruction Scheduler: task_valid
  - Instruction Scheduler: task_ready → task_ready
```

### 3.2 存储子系统连接

#### Instruction Scheduler ↔ Global Buffer
```
Instruction Scheduler:
  - global_buffer_addr[ADDR_WIDTH-1:0] → Global Buffer: addr
  - global_buffer_wdata[DATA_WIDTH-1:0] → Global Buffer: wdata
  - global_buffer_we → Global Buffer: we
  - global_buffer_ce → Global Buffer: ce
  - Global Buffer: rdata[DATA_WIDTH-1:0] → global_buffer_rdata
```

#### Instruction Scheduler ↔ DMA Controller
```
Instruction Scheduler:
  - dma_addr[ADDR_WIDTH-1:0] → DMA Controller: buffer_addr
  - dma_wdata[DATA_WIDTH-1:0] → DMA Controller: buffer_wdata
  - dma_we → DMA Controller: buffer_we
  - dma_ce → DMA Controller: buffer_ce
  - DMA Controller: buffer_rdata[DATA_WIDTH-1:0] → dma_rdata
  - DMA Controller: dma_done → dma_done
  - DMA Controller: dma_busy → dma_busy
```

### 3.3 计算子系统连接

#### Instruction Scheduler ↔ PE Array
```
Instruction Scheduler:
  - pe_array_input[DATA_WIDTH-1:0][63:0] → PE Array: pe_input
  - PE Array: pe_output[DATA_WIDTH-1:0][63:0] → pe_array_output
  - pe_array_valid → PE Array: pe_valid
  - PE Array: pe_ready → pe_array_ready
  - PE Array: pe_done → pe_array_done
```

#### PE Array ↔ Network-on-Chip
```
PE Array:
  - noc_data_out[DATA_WIDTH-1:0][63:0] → NoC: data_in
  - noc_valid_out[63:0] → NoC: valid_in
  - noc_ready_out[63:0] → NoC: ready_in
  - NoC: data_out[DATA_WIDTH-1:0][63:0] → noc_data_in
  - NoC: valid_out[63:0] → noc_valid_in
  - NoC: ready_out[63:0] → noc_ready_in
```

### 3.4 特殊功能单元连接

#### Instruction Scheduler ↔ Conv Engine
```
Instruction Scheduler:
  - conv_valid → Conv Engine: valid
  - Conv Engine: ready → conv_ready
```

#### Instruction Scheduler ↔ Matmul Engine
```
Instruction Scheduler:
  - matmul_valid → Matmul Engine: valid
  - Matmul Engine: ready → matmul_ready
```

#### Instruction Scheduler ↔ Pooling Unit
```
Instruction Scheduler:
  - pool_valid → Pooling Unit: valid
  - Pooling Unit: ready → pool_ready
```

#### Instruction Scheduler ↔ Activation Unit
```
Instruction Scheduler:
  - activation_valid → Activation Unit: valid
  - Activation Unit: ready → activation_ready
```

#### Instruction Scheduler ↔ Batch Normalization
```
Instruction Scheduler:
  - bn_valid → Batch Normalization: valid
  - Batch Normalization: ready → bn_ready
```

#### Instruction Scheduler ↔ Softmax Unit
```
Instruction Scheduler:
  - softmax_valid → Softmax Unit: valid
  - Softmax Unit: ready → softmax_ready
```

### 3.5 数据操作单元连接

#### Instruction Scheduler ↔ Element-wise Op
```
Instruction Scheduler:
  - elementwise_valid → Element-wise Op: valid
  - Element-wise Op: ready → elementwise_ready
```

#### Instruction Scheduler ↔ Concat Unit
```
Instruction Scheduler:
  - concat_valid → Concat Unit: valid
  - Concat Unit: ready → concat_ready
```

#### Instruction Scheduler ↔ Reshape Unit
```
Instruction Scheduler:
  - reshape_valid → Reshape Unit: valid
  - Reshape Unit: ready → reshape_ready
```

#### Instruction Scheduler ↔ Transpose Unit
```
Instruction Scheduler:
  - transpose_valid → Transpose Unit: valid
  - Transpose Unit: ready → transpose_ready
```

#### Instruction Scheduler ↔ Reduction Unit
```
Instruction Scheduler:
  - reduction_valid → Reduction Unit: valid
  - Reduction Unit: ready → reduction_ready
```

#### Instruction Scheduler ↔ Broadcast Unit
```
Instruction Scheduler:
  - broadcast_valid → Broadcast Unit: valid
  - Broadcast Unit: ready → broadcast_ready
```

#### Instruction Scheduler ↔ Slice Unit
```
Instruction Scheduler:
  - slice_valid → Slice Unit: valid
  - Slice Unit: ready → slice_ready
```

#### Instruction Scheduler ↔ Tile Unit
```
Instruction Scheduler:
  - tile_valid → Tile Unit: valid
  - Tile Unit: ready → tile_ready
```

#### Instruction Scheduler ↔ Pad Unit
```
Instruction Scheduler:
  - pad_valid → Pad Unit: valid
  - Pad Unit: ready → pad_ready
```

### 3.6 工具模块连接

#### Instruction Scheduler ↔ Quantization Unit
```
Instruction Scheduler:
  - quant_valid → Quantization Unit: valid
  - Quantization Unit: ready → quant_ready
```

#### Instruction Scheduler ↔ Dequantization Unit
```
Instruction Scheduler:
  - dequant_valid → Dequantization Unit: valid
  - Dequantization Unit: ready → dequant_ready
```

#### Instruction Scheduler ↔ Data Rearrange
```
Instruction Scheduler:
  - rearrange_valid → Data Rearrange: valid
  - Data Rearrange: ready → rearrange_ready
```

### 3.7 控制模块连接

#### Barrier Synchronizer
```
Instruction Scheduler:
  - barrier_sync → Barrier Synchronizer: sync_req
  - barrier_valid → Barrier Synchronizer: sync_valid
  - Barrier Synchronizer: sync_ready → barrier_ready
  - Barrier Synchronizer: sync_done → barrier_done
```

#### Load Balancer
```
PE Array:
  - pe_load[7:0][63:0] → Load Balancer: pe_load
Instruction Scheduler:
  - load_balance_en → Load Balancer: load_balance_en
Load Balancer:
  - target_pe[4:0] → Instruction Scheduler: target_pe
```

#### Performance Counter
```
Instruction Scheduler:
  - perf_counter_en → Performance Counter: enable
Performance Counter:
  - cycle_count[31:0] → Instruction Scheduler
  - op_count[31:0] → Instruction Scheduler
```

#### Config Register
```
Instruction Scheduler:
  - config_data[31:0] → Config Register: config_data
  - config_valid → Config Register: config_valid
  - config_addr[7:0] → Config Register: config_addr
Config Register:
  - config_ready → Instruction Scheduler
```

#### Clock Gating
```
Instruction Scheduler:
  - clock_gating_en → Clock Gating: enable
Clock Gating:
  - gated_clk → 各模块时钟输入
```

#### Power Gating
```
Instruction Scheduler:
  - power_gating_en → Power Gating: enable
Power Gating:
  - power_down → 各模块电源控制
```

### 3.8 中断控制连接

#### Interrupt Controller
```
Host Interface:
  - interrupt_req → Interrupt Controller: interrupt_req
  - interrupt_ack ← Interrupt Controller: interrupt_ack
  - interrupt_id[7:0] → Interrupt Controller: interrupt_id
Interrupt Controller:
  - interrupt → Host Interface: interrupt
```

## 4. 操作码到模块的映射

| 操作码 | 模块 | 描述 |
|--------|------|------|
| OP_CONV (3'd0) | Conv Engine | 卷积操作 |
| OP_MATMUL (3'd1) | Matmul Engine | 矩阵乘法 |
| OP_POOL (3'd2) | Pooling Unit | 池化操作 |
| OP_ACTIVATION (3'd3) | Activation Unit | 激活函数 |
| OP_BATCHNORM (3'd4) | Batch Normalization | 批归一化 |
| OP_RESHAPE (3'd5) | Reshape Unit | 重塑操作 |
| OP_CONCAT (3'd6) | Concat Unit | 拼接操作 |
| OP_NOP (3'd7) | - | 空操作 |

## 5. 数据路径示例

### 5.1 卷积操作数据流

```
1. Host接收卷积指令
2. Instruction Decoder解码
3. Task Manager创建任务
4. Instruction Scheduler调度
5. DMA从DRAM加载权重到Global Buffer
6. DMA从DRAM加载输入数据到Global Buffer
7. Global Buffer → PE Array
8. PE Array执行卷积计算
9. PE Array → Global Buffer
10. DMA从Global Buffer写回DRAM
11. Host返回结果
```

### 5.2 矩阵乘法数据流

```
1. Host接收矩阵乘法指令
2. Instruction Decoder解码
3. Task Manager创建任务
4. Instruction Scheduler调度
5. DMA从DRAM加载矩阵A到Global Buffer
6. DMA从DRAM加载矩阵B到Global Buffer
7. Global Buffer → Matmul Engine
8. Matmul Engine执行矩阵乘法
9. Matmul Engine → Global Buffer
10. DMA从Global Buffer写回DRAM
11. Host返回结果
```

### 5.3 池化操作数据流

```
1. Host接收池化指令
2. Instruction Decoder解码
3. Task Manager创建任务
4. Instruction Scheduler调度
5. DMA从DRAM加载特征图到Global Buffer
6. Global Buffer → Pooling Unit
7. Pooling Unit执行池化
8. Pooling Unit → Global Buffer
9. DMA从Global Buffer写回DRAM
10. Host返回结果
```

## 6. 时序关系

### 6.1 握手协议

所有模块间通信使用AXI-Stream握手协议：

```
VALID 信号：表示数据有效
READY 信号：表示接收方准备好
数据传输条件：VALID && READY
```

### 6.2 时钟域

```
主时钟域：clk
复位信号：rst_n (低有效)
时钟门控：clock_gating_en
```

### 6.3 流水线阶段

```
阶段1: 指令解码
阶段2: 任务调度
阶段3: 数据加载
阶段4: 计算执行
阶段5: 结果存储
阶段6: 数据回写
```

## 7. 性能优化机制

### 7.1 并行计算

- 64个PE并行计算
- 多个功能单元并行工作
- DMA与计算重叠执行

### 7.2 数据复用

- Global Buffer缓存数据
- PE间数据共享
- 权重数据复用

### 7.3 稀疏优化

- 零跳过：跳过零值计算
- 稀疏压缩：压缩稀疏数据
- 减少内存访问

### 7.4 量化优化

- INT8/INT16量化
- 减少计算复杂度
- 提高能效比

## 8. 错误处理

### 8.1 超时检测

- 任务执行超时
- DMA传输超时
- PE阵列超时

### 8.2 错误报告

- 状态寄存器
- 中断信号
- 错误码

### 8.3 恢复机制

- 软复位
- 任务重新调度
- 数据重新加载

## 9. 配置和调试

### 9.1 配置寄存器

- PE配置
- 缓冲区大小
- 时钟频率
- 功耗模式

### 9.2 性能计数器

- 周期计数
- 操作计数
- 吞吐量统计

### 9.3 调试接口

- 状态监控
- 性能分析
- 错误追踪

## 10. 扩展性

### 10.1 PE数量扩展

- 修改PE_ROWS和PE_COLS参数
- 调整NoC拓扑
- 更新调度器

### 10.2 功能单元扩展

- 添加新的操作码
- 实现新的功能单元
- 更新调度逻辑

### 10.3 存储扩展

- 增加Global Buffer大小
- 添加多级缓存
- 优化DMA带宽

## 总结

NPU微架构通过模块化设计实现了完整的神经网络处理能力，包括：

1. **完整的控制流**：从指令接收到结果返回
2. **高效的数据流**：多级存储和DMA传输
3. **强大的计算能力**：64个PE和多个专用引擎
4. **丰富的功能单元**：支持各种神经网络操作
5. **灵活的通信机制**：片上网络和握手协议
6. **全面的优化机制**：并行、复用、稀疏、量化
7. **可靠的控制机制**：调度、同步、负载均衡
8. **完善的工具支持**：性能计数、配置、调试

这种架构设计使得NPU能够高效地执行各种神经网络推理任务。
