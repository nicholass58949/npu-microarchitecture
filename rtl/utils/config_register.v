`include "../common/npu_definitions.vh"

module config_register (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] config_data,
    input wire config_valid,
    output wire config_ready,
    
    output wire [15:0] pe_config [0:63],
    output wire [15:0] memory_config,
    output wire [15:0] network_config
);

    reg [15:0] pe_config_reg [0:63];
    reg [15:0] memory_config_reg;
    reg [15:0] network_config_reg;
    reg [2:0] config_state;
    reg [6:0] config_addr;
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
            for (integer i = 0; i < 64; i = i + 1) begin
                pe_config_reg[i] <= 16'd0;
            end
            memory_config_reg <= 16'd0;
            network_config_reg <= 16'd0;
            config_state <= IDLE;
            config_addr <= 7'd0;
            config_ready_reg <= 1'b1;
        end else begin
            case (config_state)
                IDLE: begin
                    config_ready_reg <= 1'b1;
                    if (config_valid && config_ready_reg) begin
                        config_addr <= config_data[6:0];
                        config_state <= WRITE;
                    end
                end
                
                WRITE: begin
                    config_ready_reg <= 1'b0;
                    if (config_addr < 7'd64) begin
                        pe_config_reg[config_addr] <= config_data;
                    end else if (config_addr == 7'd64) begin
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
