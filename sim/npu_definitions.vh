`ifndef NPU_DEFINITIONS_V
`define NPU_DEFINITIONS_V

`define DATA_WIDTH 16
`define ADDR_WIDTH 32
`define PE_ROWS 8
`define PE_COLS 8
`define MAC_WIDTH 32
`define ACC_WIDTH 40
`define BUFFER_SIZE 1024
`define CHANNEL_WIDTH 8

`define OP_CONV 3'd0
`define OP_MATMUL 3'd1
`define OP_POOL 3'd2
`define OP_ACTIVATION 3'd3
`define OP_BATCHNORM 3'd4
`define OP_RESHAPE 3'd5
`define OP_CONCAT 3'd6
`define OP_NOP 3'd7

`define ACT_NONE 2'd0
`define ACT_RELU 2'd1
`define ACT_RELU6 2'd2
`define ACT_SIGMOID 2'd3

`define POOL_NONE 2'd0
`define POOL_MAX 2'd1
`define POOL_AVG 2'd2
`define POOL_GLOBAL 2'd3

`define MEM_IDLE 3'd0
`define MEM_READ 3'd1
`define MEM_WRITE 3'd2
`define MEM_WAIT 3'd3
`define MEM_DONE 3'd4
`define MEM_ERROR 3'd5

`endif
