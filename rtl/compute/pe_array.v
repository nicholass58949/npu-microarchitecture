`include "../common/npu_definitions.vh"

module pe_array (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] pe_input [0:63],
    output wire [15:0] pe_output [0:63],
    input wire pe_valid,
    output wire pe_ready,
    output wire pe_done,
    
    input wire [15:0] noc_data_in [0:63],
    output wire [15:0] noc_data_out [0:63],
    input wire noc_valid_in [0:63],
    output wire noc_valid_out [0:63],
    output wire noc_ready_in [0:63],
    input wire noc_ready_out [0:63]
);

    wire [15:0] pe_input_data [0:63];
    wire [15:0] pe_weight_data [0:63];
    wire [39:0] pe_output_data [0:63];
    wire pe_output_valid [0:63];
    wire pe_output_ready [0:63];
    wire pe_input_ready [0:63];
    wire pe_weight_ready [0:63];
    
    reg [5:0] pe_count;
    reg [7:0] iteration_count;
    reg pe_done_reg;
    reg pe_ready_reg;
    reg [5:0] input_ready_count;
    reg [5:0] weight_ready_count;
    integer k;

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : row_gen
            for (j = 0; j < 8; j = j + 1) begin : col_gen
                localparam pe_idx = i * 8 + j;
                
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
                    .act_type(2'd1),
                    .pe_id(pe_idx[3:0])
                );
                
                assign pe_output[pe_idx] = pe_output_data[pe_idx][15:0];
            end
        end
    endgenerate

    assign pe_ready = pe_ready_reg;
    assign pe_done = pe_done_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pe_count <= 6'd0;
            iteration_count <= 8'd0;
            pe_done_reg <= 1'b0;
            pe_ready_reg <= 1'b0;
            input_ready_count <= 6'd0;
            weight_ready_count <= 6'd0;
        end else begin
            input_ready_count <= 6'd0;
            weight_ready_count <= 6'd0;
            
            for (k = 0; k < 64; k = k + 1) begin
                if (pe_input_ready[k]) begin
                    input_ready_count <= input_ready_count + 1'b1;
                end
                if (pe_weight_ready[k]) begin
                    weight_ready_count <= weight_ready_count + 1'b1;
                end
            end
            
            if (input_ready_count == 6'd63 && weight_ready_count == 6'd63) begin
                pe_ready_reg <= 1'b1;
            end else begin
                pe_ready_reg <= 1'b0;
            end
            
            if (pe_valid && pe_ready_reg) begin
                if (pe_count < 6'd63) begin
                    pe_count <= pe_count + 1'b1;
                end else begin
                    pe_count <= 6'd0;
                    if (iteration_count < 8'd255) begin
                        iteration_count <= iteration_count + 1'b1;
                    end else begin
                        pe_done_reg <= 1'b1;
                    end
                end
            end
        end
    end

endmodule
