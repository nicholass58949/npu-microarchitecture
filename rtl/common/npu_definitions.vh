`ifndef NPU_DEFINITIONS_V
`define NPU_DEFINITIONS_V

parameter DATA_WIDTH = 16;
parameter ADDR_WIDTH = 32;
parameter PE_ROWS = 8;
parameter PE_COLS = 8;
parameter MAC_WIDTH = 32;
parameter ACC_WIDTH = 40;
parameter BUFFER_SIZE = 1024;
parameter CHANNEL_WIDTH = 8;

typedef enum logic [2:0] {
    OP_CONV = 3'd0,
    OP_MATMUL = 3'd1,
    OP_POOL = 3'd2,
    OP_ACTIVATION = 3'd3,
    OP_BATCHNORM = 3'd4,
    OP_RESHAPE = 3'd5,
    OP_CONCAT = 3'd6,
    OP_NOP = 3'd7
} opcode_t;

typedef enum logic [1:0] {
    ACT_NONE = 2'd0,
    ACT_RELU = 2'd1,
    ACT_RELU6 = 2'd2,
    ACT_SIGMOID = 2'd3
} activation_type_t;

typedef enum logic [1:0] {
    POOL_NONE = 2'd0,
    POOL_MAX = 2'd1,
    POOL_AVG = 2'd2,
    POOL_GLOBAL = 2'd3
} pool_type_t;

typedef enum logic [2:0] {
    MEM_IDLE = 3'd0,
    MEM_READ = 3'd1,
    MEM_WRITE = 3'd2,
    MEM_WAIT = 3'd3,
    MEM_DONE = 3'd4,
    MEM_ERROR = 3'd5
} mem_state_t;

`endif
