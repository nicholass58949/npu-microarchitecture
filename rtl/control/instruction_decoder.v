`include "../common/npu_definitions.vh"

module instruction_decoder (
    input wire clk,
    input wire rst_n,
    
    input wire [31:0] cmd,
    input wire cmd_valid,
    output reg cmd_ready,
    
    output reg [2:0] opcode,
    output reg [31:0] src_addr,
    output reg [31:0] dst_addr,
    output reg [31:0] param1,
    output reg [31:0] param2,
    output reg decode_valid,
    input wire decode_ready
);

    reg [2:0] decoder_state;

    localparam IDLE = 3'd0;
    localparam DECODE = 3'd1;
    localparam OUTPUT = 3'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd_ready <= 1'b1;
            opcode <= 3'd0;
            src_addr <= {32{1'b0}};
            dst_addr <= {32{1'b0}};
            param1 <= 32'd0;
            param2 <= 32'd0;
            decode_valid <= 1'b0;
            decoder_state <= IDLE;
        end else begin
            case (decoder_state)
                IDLE: begin
                    cmd_ready <= 1'b1;
                    decode_valid <= 1'b0;
                    if (cmd_valid && cmd_ready) begin
                        decoder_state <= DECODE;
                    end
                end
                
                DECODE: begin
                    cmd_ready <= 1'b0;
                    opcode <= cmd[31:29];
                    src_addr <= cmd[28:17];
                    dst_addr <= cmd[16:5];
                    param1 <= {16'd0, cmd[28:13]};
                    param2 <= {16'd0, cmd[12:0]};
                    decoder_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    if (decode_ready) begin
                        decode_valid <= 1'b1;
                        decoder_state <= IDLE;
                    end
                end
                
                default: decoder_state <= IDLE;
            endcase
        end
    end

endmodule
