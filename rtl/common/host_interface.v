`include "../common/npu_definitions.vh"

module host_interface (
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,
    
    output wire [15:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast,
    
    output wire [31:0] scheduler_cmd,
    output wire scheduler_valid,
    input wire scheduler_ready,
    
    output wire [31:0] status,
    output wire interrupt_req,
    input wire interrupt_ack,
    output wire [7:0] interrupt_id,
    output wire interrupt
);

    reg [31:0] cmd_fifo [0:15];
    reg [3:0] cmd_wr_ptr, cmd_rd_ptr;
    reg cmd_full, cmd_empty;
    
    reg [15:0] resp_fifo [0:15];
    reg [3:0] resp_wr_ptr, resp_rd_ptr;
    reg resp_full, resp_empty;
    
    reg [31:0] status_reg;
    reg interrupt_reg;
    reg interrupt_req_reg;
    reg [7:0] interrupt_id_reg;
    
    reg [31:0] cmd_reg;
    reg cmd_valid_reg;
    
    // Calculate next pointers (used in always block)
    wire [3:0] cmd_wr_ptr_next = cmd_wr_ptr + 1'b1;
    wire [3:0] cmd_rd_ptr_next = cmd_rd_ptr + 1'b1;
    wire [3:0] resp_rd_ptr_next = resp_rd_ptr + 1'b1;
    
    assign s_axis_tready = ~cmd_full;
    assign scheduler_cmd = cmd_reg;
    assign scheduler_valid = cmd_valid_reg;
    assign m_axis_tdata = resp_fifo[resp_rd_ptr];
    assign m_axis_tvalid = ~resp_empty;
    // FIX: Correct m_axis_tlast logic for 4-bit pointers
    assign m_axis_tlast = (resp_rd_ptr_next == resp_wr_ptr) && ~resp_empty;
    assign status = status_reg;
    assign interrupt_req = interrupt_req_reg;
    assign interrupt_id = interrupt_id_reg;
    assign interrupt = interrupt_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd_wr_ptr <= 4'd0;
            cmd_rd_ptr <= 4'd0;
            cmd_full <= 1'b0;
            cmd_empty <= 1'b1;
            resp_wr_ptr <= 4'd0;
            resp_rd_ptr <= 4'd0;
            resp_full <= 1'b0;
            resp_empty <= 1'b1;
            status_reg <= 32'd0;
            interrupt_reg <= 1'b0;
            interrupt_req_reg <= 1'b0;
            interrupt_id_reg <= 8'd0;
            cmd_reg <= 32'd0;
            cmd_valid_reg <= 1'b0;
        end else begin
            // Write command from AXI-Stream
            if (s_axis_tvalid && s_axis_tready) begin
                cmd_fifo[cmd_wr_ptr] <= s_axis_tdata;
                cmd_wr_ptr <= cmd_wr_ptr_next;
                cmd_empty <= 1'b0;
                // Full condition: next write pointer equals read pointer
                if (cmd_wr_ptr_next == cmd_rd_ptr) begin
                    cmd_full <= 1'b1;
                end else begin
                    cmd_full <= 1'b0;
                end
            end
            
            // Acknowledge scheduler consumption
            if (scheduler_ready && cmd_valid_reg) begin
                cmd_valid_reg <= 1'b0;
            end
            
            // Read command from FIFO to scheduler
            if (~cmd_valid_reg && ~cmd_empty) begin
                cmd_reg <= cmd_fifo[cmd_rd_ptr];
                cmd_valid_reg <= 1'b1;
                cmd_rd_ptr <= cmd_rd_ptr + 1'b1;
                // Empty condition: next read pointer equals write pointer
                if (cmd_rd_ptr_next == cmd_wr_ptr) begin
                    cmd_empty <= 1'b1;
                end else begin
                    cmd_empty <= 1'b0;
                end
                cmd_full <= 1'b0;
            end
            
            // Read response from FIFO to AXI-Stream
            if (m_axis_tready && ~resp_empty) begin
                resp_rd_ptr <= resp_rd_ptr_next;
                resp_full <= 1'b0;
                // Empty condition: next read pointer equals write pointer
                if (resp_rd_ptr_next == resp_wr_ptr) begin
                    resp_empty <= 1'b1;
                end else begin
                    resp_empty <= 1'b0;
                end
            end
            
            if (interrupt_req_reg && interrupt_ack) begin
                interrupt_req_reg <= 1'b0;
                interrupt_reg <= 1'b1;
                interrupt_id_reg <= 8'd0;
            end
            
            status_reg <= {30'd0, cmd_full, resp_full};
            interrupt_req_reg <= cmd_full && resp_empty;
        end
    end

endmodule
