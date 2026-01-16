`include "../common/npu_definitions.vh"

module pe_array (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] pe_input [PE_ROWS*PE_COLS-1:0],
    output wire [DATA_WIDTH-1:0] pe_output [PE_ROWS*PE_COLS-1:0],
    input wire pe_valid,
    output wire pe_ready,
    
    input wire [DATA_WIDTH-1:0] noc_data_in [PE_ROWS*PE_COLS-1:0],
    output wire [DATA_WIDTH-1:0] noc_data_out [PE_ROWS*PE_COLS-1:0],
    input wire noc_valid_in [PE_ROWS*PE_COLS-1:0],
    output wire noc_valid_out [PE_ROWS*PE_COLS-1:0],
    output wire noc_ready_in [PE_ROWS*PE_COLS-1:0],
    input wire noc_ready_out [PE_ROWS*PE_COLS-1:0]
);

    wire [DATA_WIDTH-1:0] pe_input_data [PE_ROWS*PE_COLS-1:0];
    wire [DATA_WIDTH-1:0] pe_weight_data [PE_ROWS*PE_COLS-1:0];
    wire [ACC_WIDTH-1:0] pe_output_data [PE_ROWS*PE_COLS-1:0];
    wire pe_output_valid [PE_ROWS*PE_COLS-1:0];
    wire pe_output_ready [PE_ROWS*PE_COLS-1:0];
    wire pe_input_ready [PE_ROWS*PE_COLS-1:0];
    wire pe_weight_ready [PE_ROWS*PE_COLS-1:0];

    genvar i, j;
    generate
        for (i = 0; i < PE_ROWS; i = i + 1) begin : row_gen
            for (j = 0; j < PE_COLS; j = j + 1) begin : col_gen
                localparam pe_idx = i * PE_COLS + j;
                
                processing_element u_pe (
                    .clk(clk),
                    .rst_n(rst_n),
                    .input_data(pe_input[pe_idx]),
                    .input_valid(pe_valid),
                    .input_ready(pe_input_ready[pe_idx]),
                    .weight_data(pe_weight_data[pe_idx]),
                    .weight_valid(pe_valid),
                    .weight_ready(pe_weight_ready[pe_idx]),
                    .output_data(pe_output_data[pe_idx]),
                    .output_valid(pe_output_valid[pe_idx]),
                    .output_ready(pe_output_ready[pe_idx]),
                    .noc_data_in(noc_data_in[pe_idx]),
                    .noc_valid_in(noc_valid_in[pe_idx]),
                    .noc_ready_in(noc_ready_in[pe_idx]),
                    .noc_data_out(noc_data_out[pe_idx]),
                    .noc_valid_out(noc_valid_out[pe_idx]),
                    .noc_ready_out(noc_ready_out[pe_idx]),
                    .act_type(ACT_RELU),
                    .pe_id(pe_idx[3:0])
                );
                
                assign pe_output[pe_idx] = pe_output_data[pe_idx][DATA_WIDTH-1:0];
            end
        end
    endgenerate

    assign pe_ready = &pe_input_ready && &pe_weight_ready;

endmodule
