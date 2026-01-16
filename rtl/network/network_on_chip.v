`include "../common/npu_definitions.vh"

module network_on_chip (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] data_in [PE_ROWS*PE_COLS-1:0],
    output wire [DATA_WIDTH-1:0] data_out [PE_ROWS*PE_COLS-1:0],
    input wire valid_in [PE_ROWS*PE_COLS-1:0],
    output wire valid_out [PE_ROWS*PE_COLS-1:0],
    output wire ready_in [PE_ROWS*PE_COLS-1:0],
    input wire ready_out [PE_ROWS*PE_COLS-1:0]
);

    wire [DATA_WIDTH-1:0] router_data_in [PE_ROWS*PE_COLS-1:0];
    wire [DATA_WIDTH-1:0] router_data_out [PE_ROWS*PE_COLS-1:0];
    wire [4:0] router_dest [PE_ROWS*PE_COLS-1:0];
    wire router_valid_in [PE_ROWS*PE_COLS-1:0];
    wire router_valid_out [PE_ROWS*PE_COLS-1:0];
    wire router_ready_in [PE_ROWS*PE_COLS-1:0];
    wire router_ready_out [PE_ROWS*PE_COLS-1:0];

    genvar i, j;
    generate
        for (i = 0; i < PE_ROWS; i = i + 1) begin : row_gen
            for (j = 0; j < PE_COLS; j = j + 1) begin : col_gen
                localparam pe_idx = i * PE_COLS + j;
                
                noc_router u_router (
                    .clk(clk),
                    .rst_n(rst_n),
                    .router_id(pe_idx),
                    .data_in(data_in[pe_idx]),
                    .data_out(data_out[pe_idx]),
                    .valid_in(valid_in[pe_idx]),
                    .valid_out(valid_out[pe_idx]),
                    .ready_in(ready_in[pe_idx]),
                    .ready_out(ready_out[pe_idx]),
                    .router_data_in(router_data_in),
                    .router_data_out(router_data_out),
                    .router_dest(router_dest),
                    .router_valid_in(router_valid_in),
                    .router_valid_out(router_valid_out),
                    .router_ready_in(router_ready_in),
                    .router_ready_out(router_ready_out)
                );
            end
        end
    endgenerate

endmodule
