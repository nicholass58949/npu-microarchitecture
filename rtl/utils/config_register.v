`include "../common/npu_definitions.vh"

module config_register (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] config_data,
    input wire config_valid,
    output wire config_ready,
    
    output wire [DATA_WIDTH-1:0] pe_config [PE_ROWS*PE_COLS-1:0],
    output wire [DATA_WIDTH-1:0] memory_config,
    output wire [DATA_WIDTH-1:0] network_config
);

    reg [DATA_WIDTH-1:0] pe_config_reg [PE_ROWS*PE_COLS-1:0];
    reg [DATA_WIDTH-1:0] memory_config_reg;
    reg [DATA_WIDTH-1:0] network_config_reg;
    reg [2:0] config_state;
    reg [4:0] config_addr;
    reg config_ready_reg;

    assign pe_config = pe_config_reg;
    assign memory_config = memory_config_reg;
    assign network_config = network_config_reg;
    assign config_ready = config_ready_reg;

    localparam IDLE = 3'd0;
    localparam WRITE = 3'd1;
    localparam DONE = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < PE_ROWS*PE_COLS; i = i + 1) begin
                pe_config_reg[i] <= {DATA_WIDTH{1'b0}};
            end
            memory_config_reg <= {DATA_WIDTH{1'b0}};
            network_config_reg <= {DATA_WIDTH{1'b0}};
            config_state <= IDLE;
            config_addr <= 5'd0;
            config_ready_reg <= 1'b1;
        end else begin
            case (config_state)
                IDLE: begin
                    config_ready_reg <= 1'b1;
                    if (config_valid && config_ready_reg) begin
                        config_addr <= config_data[4:0];
                        config_state <= WRITE;
                    end
                end
                
                WRITE: begin
                    config_ready_reg <= 1'b0;
                    if (config_addr < PE_ROWS*PE_COLS) begin
                        pe_config_reg[config_addr] <= config_data;
                    end else if (config_addr == PE_ROWS*PE_COLS) begin
                        memory_config_reg <= config_data;
                    end else begin
                        network_config_reg <= config_data;
                    end
                    config_state <= DONE;
                end
                
                DONE: begin
                    config_ready_reg <= 1'b1;
                    config_state <= IDLE;
                end
                
                default: config_state <= IDLE;
            endcase
        end
    end

endmodule
