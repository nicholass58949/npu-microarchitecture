`include "../common/npu_definitions.vh"

module instruction_decoder (
    input wire clk,
    input wire rst_n,
    
    input wire [31:0] instruction,
    input wire valid,
    output reg ready,
    
    output opcode_t opcode,
    output reg [DATA_WIDTH-1:0] operand_a,
    output reg [DATA_WIDTH-1:0] operand_b,
    output reg [ADDR_WIDTH-1:0] addr,
    output reg [7:0] immediate,
    output reg [3:0] dest_reg,
    output reg [3:0] src_reg_a,
    output reg [3:0] src_reg_b
);

    reg [2:0] decoder_state;

    localparam IDLE = 3'd0;
    localparam DECODE = 3'd1;
    localparam OUTPUT = 3'd2;

    assign opcode = opcode_t(instruction[31:29]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready <= 1'b1;
            operand_a <= {DATA_WIDTH{1'b0}};
            operand_b <= {DATA_WIDTH{1'b0}};
            addr <= {ADDR_WIDTH{1'b0}};
            immediate <= 8'd0;
            dest_reg <= 4'd0;
            src_reg_a <= 4'd0;
            src_reg_b <= 4'd0;
            decoder_state <= IDLE;
        end else begin
            case (decoder_state)
                IDLE: begin
                    ready <= 1'b1;
                    if (valid && ready) begin
                        decoder_state <= DECODE;
                    end
                end
                
                DECODE: begin
                    ready <= 1'b0;
                    operand_a <= instruction[28:13];
                    operand_b <= instruction[12:0];
                    addr <= {19'd0, instruction[12:0]};
                    immediate <= instruction[7:0];
                    dest_reg <= instruction[3:0];
                    src_reg_a <= instruction[7:4];
                    src_reg_b <= instruction[11:8];
                    decoder_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    decoder_state <= IDLE;
                end
                
                default: decoder_state <= IDLE;
            endcase
        end
    end

endmodule
