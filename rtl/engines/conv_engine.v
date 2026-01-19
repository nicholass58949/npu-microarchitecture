`include "../common/npu_definitions.vh"

module conv_engine (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] input_data [0:63],
    input wire [15:0] weight_data [0:63],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] output_data,
    output wire valid_out,
    input wire ready_out,
    
    input wire [3:0] kernel_size,
    input wire [3:0] stride,
    input wire [3:0] padding
);

    reg [15:0] pe_input [0:63];
    wire [15:0] pe_output [0:63];
    reg pe_valid;
    wire pe_ready;
    reg [15:0] output_data_reg;
    reg valid_out_reg;
    reg [2:0] conv_state;
    integer i;

    assign output_data = output_data_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = (conv_state == 3'd0);

    pe_array u_pe_array (
        .clk(clk),
        .rst_n(rst_n),
        .pe_input(pe_input),
        .pe_output(pe_output),
        .pe_valid(pe_valid),
        .pe_ready(pe_ready)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            output_data_reg <= 16'd0;
            valid_out_reg <= 1'b0;
            conv_state <= 3'd0;
            pe_valid <= 1'b0;
            for (i = 0; i < 64; i = i + 1) begin
                pe_input[i] <= 16'd0;
            end
        end else begin
            case (conv_state)
                3'd0: begin
                    if (valid_in && ready_in) begin
                        for (i = 0; i < 64; i = i + 1) begin
                            pe_input[i] <= input_data[i] * weight_data[i];
                        end
                        pe_valid <= 1'b1;
                        conv_state <= 3'd1;
                    end
                end
                
                3'd1: begin
                    pe_valid <= 1'b0;
                    if (pe_ready) begin
                        output_data_reg <= pe_output[0];
                        valid_out_reg <= 1'b1;
                        conv_state <= 3'd2;
                    end
                end
                
                3'd2: begin
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        conv_state <= 3'd0;
                    end
                end
                
                default: conv_state <= 3'd0;
            endcase
        end
    end

endmodule
