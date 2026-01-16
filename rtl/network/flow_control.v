`include "../common/npu_definitions.vh"

module flow_control (
    input wire clk,
    input wire rst_n,
    
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    output wire ready_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire valid_out,
    input wire ready_out,
    
    input wire credit_available
);

    reg [DATA_WIDTH-1:0] data_out_reg;
    reg valid_out_reg;
    reg ready_in_reg;
    reg [7:0] credit_count;

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;
    assign ready_in = ready_in_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= {DATA_WIDTH{1'b0}};
            valid_out_reg <= 1'b0;
            ready_in_reg <= 1'b0;
            credit_count <= 8'd0;
        end else begin
            if (credit_available) begin
                credit_count <= credit_count + 1'b1;
            end
            
            if (valid_in && ready_in_reg && credit_count > 0) begin
                data_out_reg <= data_in;
                valid_out_reg <= 1'b1;
                credit_count <= credit_count - 1'b1;
            end
            
            if (ready_out && valid_out_reg) begin
                valid_out_reg <= 1'b0;
            end
            
            ready_in_reg <= (credit_count > 0) && !valid_out_reg;
        end
    end

endmodule
