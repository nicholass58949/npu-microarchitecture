`include "../common/npu_definitions.vh"

// Simplified PE Array (8x8)
// Removed Network-on-Chip dependencies

module pe_array (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] pe_input [0:63],
    output wire [15:0] pe_output [0:63],
    input wire pe_valid,
    output wire pe_ready,
    output wire pe_done
);

    wire [15:0] pe_output_data [0:63];
    wire pe_output_valid [0:63];
    wire pe_output_ready [0:63];
    wire pe_input_ready [0:63];
    
    reg [7:0] iteration_count;
    reg pe_done_reg;
    reg pe_ready_reg;
    reg [5:0] input_ready_count;
    
    integer k;
    genvar i, j;
    
    // Generate 8x8 PE array
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
                    .weight_data(pe_input[pe_idx]),  // Use input as weight for simplicity
                    .weight_valid(pe_valid),
                    .weight_ready(),
                    .output_data(pe_output_data[pe_idx]),
                    .output_valid(pe_output_valid[pe_idx]),
                    .output_ready(pe_output_ready[pe_idx]),
                    .act_type(2'd1),
                    .pe_id(pe_idx[5:0])
                );
                
                assign pe_output[pe_idx] = pe_output_data[pe_idx];
                assign pe_output_ready[pe_idx] = 1'b1;
            end
        end
    endgenerate

    assign pe_ready = pe_ready_reg;
    assign pe_done = pe_done_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            iteration_count <= 8'd0;
            pe_done_reg <= 1'b0;
            pe_ready_reg <= 1'b0;
            input_ready_count <= 6'd0;
        end else begin
            input_ready_count <= 6'd0;
            
            // Count how many PEs are ready
            for (k = 0; k < 64; k = k + 1) begin
                if (pe_input_ready[k]) begin
                    input_ready_count <= input_ready_count + 1'b1;
                end
            end
            
            // All PEs ready
            if (input_ready_count == 6'd63) begin
                pe_ready_reg <= 1'b1;
            end else begin
                pe_ready_reg <= 1'b0;
            end
            
            // Execute computation
            if (pe_valid && pe_ready_reg) begin
                iteration_count <= iteration_count + 1'b1;
                if (iteration_count >= 8'd10) begin
                    pe_done_reg <= 1'b1;
                    iteration_count <= 8'd0;
                end
            end else begin
                pe_done_reg <= 1'b0;
            end
        end
    end

endmodule
