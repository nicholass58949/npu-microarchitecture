`include "../common/npu_definitions.vh"

module processing_element (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] input_data,
    input wire input_valid,
    output reg input_ready,
    
    input wire [15:0] weight_data,
    input wire weight_valid,
    output reg weight_ready,
    
    output wire [39:0] output_data,
    output wire output_valid,
    input wire output_ready,
    
    input wire [15:0] noc_data_in,
    input wire noc_valid_in,
    output wire noc_ready_in,
    output wire [15:0] noc_data_out,
    output wire noc_valid_out,
    input wire noc_ready_out,
    
    input wire [1:0] act_type,
    input wire [3:0] pe_id
);

    wire [15:0] reg_rdata_a, reg_rdata_b;
    wire [39:0] mac_acc_out;
    wire mac_done;
    wire [15:0] act_data_out;
    wire act_valid_out;
    wire [3:0] pe_id_plus_one;
    
    reg [15:0] input_reg;
    reg [15:0] weight_reg;
    reg [39:0] acc_reg;
    reg [2:0] pe_state;
    reg acc_rst;

    assign pe_id_plus_one = pe_id + 1'b1;

    localparam IDLE = 3'd0;
    localparam LOAD = 3'd1;
    localparam COMPUTE = 3'd2;
    localparam ACTIVATE = 3'd3;
    localparam OUTPUT = 3'd4;

    assign output_data = act_data_out;
    assign output_valid = act_valid_out && output_ready;

    pe_register_file u_pe_register_file (
        .clk(clk),
        .rst_n(rst_n),
        .wdata(input_data),
        .waddr(pe_id[3:0]),
        .we(input_valid && input_ready),
        .raddr_a(pe_id[3:0]),
        .raddr_b(pe_id_plus_one[3:0]),
        .rdata_a(reg_rdata_a),
        .rdata_b(reg_rdata_b)
    );

    mac_unit u_mac_unit (
        .clk(clk),
        .rst_n(rst_n),
        .operand_a(reg_rdata_a),
        .operand_b(weight_reg),
        .accumulator_in(acc_reg),
        .valid(pe_state == COMPUTE),
        .rst_acc(acc_rst),
        .accumulator_out(mac_acc_out),
        .done(mac_done)
    );

    activation_unit u_activation_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(mac_acc_out),
        .valid(mac_done),
        .act_type(act_type),
        .data_out(act_data_out),
        .valid_out(act_valid_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_ready <= 1'b0;
            weight_ready <= 1'b0;
            input_reg <= {16{1'b0}};
            weight_reg <= {16{1'b0}};
            acc_reg <= {40{1'b0}};
            pe_state <= IDLE;
            acc_rst <= 1'b0;
        end else begin
            case (pe_state)
                IDLE: begin
                    input_ready <= 1'b1;
                    weight_ready <= 1'b1;
                    acc_rst <= 1'b1;
                    if (input_valid && weight_valid) begin
                        input_reg <= input_data;
                        weight_reg <= weight_data;
                        pe_state <= LOAD;
                    end
                end
                
                LOAD: begin
                    input_ready <= 1'b0;
                    weight_ready <= 1'b0;
                    acc_rst <= 1'b0;
                    pe_state <= COMPUTE;
                end
                
                COMPUTE: begin
                    if (mac_done) begin
                        acc_reg <= mac_acc_out;
                        pe_state <= ACTIVATE;
                    end
                end
                
                ACTIVATE: begin
                    if (act_valid_out) begin
                        pe_state <= OUTPUT;
                    end
                end
                
                OUTPUT: begin
                    if (output_ready) begin
                        pe_state <= IDLE;
                    end
                end
                
                default: pe_state <= IDLE;
            endcase
        end
    end

endmodule
