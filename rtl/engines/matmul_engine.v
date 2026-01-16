`include "../common/npu_definitions.vh"

module matmul_engine (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] matrix_a [0:63],
    input wire [DATA_WIDTH-1:0] matrix_b [0:63],
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] output_data [0:63],
    output wire valid_out,
    input wire ready_out,
    
    input wire [3:0] m_dim,
    input wire [3:0] n_dim,
    input wire [3:0] k_dim
);

    wire [DATA_WIDTH-1:0] pe_input [PE_ROWS*PE_COLS-1:0];
    wire [DATA_WIDTH-1:0] pe_output [PE_ROWS*PE_COLS-1:0];
    wire pe_valid, pe_ready;
    reg [DATA_WIDTH-1:0] output_data_reg [0:63];
    reg valid_out_reg;
    reg [2:0] matmul_state;
    reg [5:0] row_idx, col_idx;

    assign output_data = output_data_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = (matmul_state == 3'd0);

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
            for (integer i = 0; i < 64; i = i + 1) begin
                output_data_reg[i] <= {DATA_WIDTH{1'b0}};
            end
            valid_out_reg <= 1'b0;
            matmul_state <= 3'd0;
            row_idx <= 6'd0;
            col_idx <= 6'd0;
        end else begin
            case (matmul_state)
                3'd0: begin
                    if (valid_in && ready_in) begin
                        row_idx <= 6'd0;
                        col_idx <= 6'd0;
                        matmul_state <= 3'd1;
                    end
                end
                
                3'd1: begin
                    for (integer i = 0; i < PE_ROWS*PE_COLS; i = i + 1) begin
                        pe_input[i] <= matrix_a[row_idx * 8 + i] * matrix_b[i * 8 + col_idx];
                    end
                    pe_valid <= 1'b1;
                    matmul_state <= 3'd2;
                end
                
                3'd2: begin
                    pe_valid <= 1'b0;
                    if (pe_ready) begin
                        output_data_reg[row_idx * 8 + col_idx] <= pe_output[row_idx * 8 + col_idx];
                        if (col_idx < 7) begin
                            col_idx <= col_idx + 1'b1;
                            matmul_state <= 3'd1;
                        end else if (row_idx < 7) begin
                            row_idx <= row_idx + 1'b1;
                            col_idx <= 6'd0;
                            matmul_state <= 3'd1;
                        end else begin
                            valid_out_reg <= 1'b1;
                            matmul_state <= 3'd3;
                        end
                    end
                end
                
                3'd3: begin
                    if (ready_out) begin
                        valid_out_reg <= 1'b0;
                        matmul_state <= 3'd0;
                    end
                end
                
                default: matmul_state <= 3'd0;
            endcase
        end
    end

endmodule
