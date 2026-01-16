`include "../common/npu_definitions.vh"

module virtual_channel (
    input wire clk,
    input wire rst_n,
    input wire [1:0] vc_id,
    
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire valid_out,
    input wire ready_out
);

    reg [DATA_WIDTH-1:0] vc_buffer [0:7];
    reg [2:0] vc_wr_ptr, vc_rd_ptr;
    reg vc_full, vc_empty;
    reg [DATA_WIDTH-1:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vc_wr_ptr <= 3'd0;
            vc_rd_ptr <= 3'd0;
            vc_full <= 1'b0;
            vc_empty <= 1'b1;
            data_out_reg <= {DATA_WIDTH{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b1;
        end else begin
            if (valid_in && ready_in_reg && !vc_full) begin
                vc_buffer[vc_wr_ptr] <= data_in;
                vc_wr_ptr <= vc_wr_ptr + 1'b1;
                vc_empty <= 1'b0;
                if (vc_wr_ptr == 3'd7) begin
                    vc_full <= 1'b1;
                end
            end
            
            if (ready_out && valid_out_reg && !vc_empty) begin
                data_out_reg <= vc_buffer[vc_rd_ptr];
                valid_out_reg <= 1'b1;
                vc_rd_ptr <= vc_rd_ptr + 1'b1;
                vc_full <= 1'b0;
                if (vc_rd_ptr == 3'd7) begin
                    vc_empty <= 1'b1;
                end
            end else begin
                valid_out_reg <= 1'b0;
            end
            
            ready_in_reg <= !vc_full;
        end
    end

endmodule
