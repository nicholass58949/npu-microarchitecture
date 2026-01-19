`include "../common/npu_definitions.vh"

module network_on_chip (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] data_in [0:63],
    output wire [15:0] data_out [0:63],
    input wire valid_in [0:63],
    output wire valid_out [0:63],
    output wire ready_in [0:63],
    input wire ready_out [0:63]
);

    wire [15:0] router_data_in [0:63];
    wire [15:0] router_data_out [0:63];
    wire [5:0] router_dest [0:63];
    wire router_valid_in [0:63];
    wire router_valid_out [0:63];
    wire router_ready_in [0:63];
    wire router_ready_out [0:63];

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : row_gen
            for (j = 0; j < 8; j = j + 1) begin : col_gen
                localparam pe_idx = i * 8 + j;
                
                noc_router u_router (
                    .clk(clk),
                    .rst_n(rst_n),
                    .router_id(pe_idx[5:0]),
                    .data_in(data_in[pe_idx]),
                    .data_out(data_out[pe_idx]),
                    .valid_in(valid_in[pe_idx]),
                    .valid_out(valid_out[pe_idx]),
                    .ready_in(ready_in[pe_idx]),
                    .ready_out(ready_out[pe_idx]),
                    .router_data_in(router_data_in),
                    .router_data_out(router_data_out),
                    .router_valid_in(router_valid_in),
                    .router_valid_out(router_valid_out),
                    .router_ready_in(router_ready_in),
                    .router_ready_out(router_ready_out),
                    .router_dest(router_dest)
                );
            end
        end
    endgenerate

endmodule
