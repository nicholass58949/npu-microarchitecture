`include "../common/npu_definitions.vh"

module sparse_compression (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:15],
    input wire valid_in,
    output wire ready_in,
    output wire [15:0] data_out [0:15],
    output wire [15:0] index_out,
    output wire valid_out,
    input wire ready_out
);

    reg [15:0] data_out_reg [0:15];
    reg [15:0] index_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [4:0] compress_state;
    reg [3:0] non_zero_count;
    reg [3:0] write_ptr;

    assign data_out = data_out_reg;
    assign index_out = index_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    localparam IDLE = 5'd0;
    localparam SCAN = 5'd1;
    localparam COMPRESS = 5'd2;
    localparam OUTPUT = 5'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 16; i = i + 1) begin
                data_out_reg[i] <= {16{1'b0}};
            end
            index_out_reg <= 16'd0;
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
            compress_state <= IDLE;
            non_zero_count <= 4'd0;
            write_ptr <= 4'd0;
        end else begin
            case (compress_state)
                IDLE: begin
                    ready_in_reg <= 1'b1;
                    if (valid_in && ready_in_reg) begin
                        compress_state <= SCAN;
                    end
                end
                
                SCAN: begin
                    ready_in_reg <= 1'b0;
                    non_zero_count <= 4'd0;
                    write_ptr <= 4'd0;
                    for (integer i = 0; i < 16; i = i + 1) begin
                        if (data_in[i] != {16{1'b0}}) begin
                            non_zero_count <= non_zero_count + 1'b1;
                        end
                    end
                    compress_state <= COMPRESS;
                end
                
                COMPRESS: begin
                    for (integer i = 0; i < 16; i = i + 1) begin
                        if (data_in[i] != {16{1'b0}}) begin
                            data_out_reg[write_ptr] <= data_in[i];
                            index_out_reg[write_ptr] <= 1'b1;
                            write_ptr <= write_ptr + 1'b1;
                        end else begin
                            index_out_reg[i] <= 1'b0;
                        end
                    end
                    compress_state <= OUTPUT;
                end
                
                OUTPUT: begin
                    valid_out_reg <= 1'b1;
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        compress_state <= IDLE;
                    end
                end
                
                default: compress_state <= IDLE;
            endcase
        end
    end

endmodule
