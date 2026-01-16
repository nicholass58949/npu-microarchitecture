`include "../common/npu_definitions.vh"

module barrier_synchronizer (
    input wire clk,
    input wire rst_n,
    
    input wire [3:0] pe_id,
    input wire pe_ready,
    output wire pe_release,
    
    input wire [3:0] barrier_count,
    input wire barrier_enable
);

    reg [3:0] ready_count;
    reg [3:0] target_count;
    reg barrier_active;
    reg release_reg;

    assign pe_release = release_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_count <= 4'd0;
            target_count <= 4'd0;
            barrier_active <= 1'b0;
            release_reg <= 1'b0;
        end else begin
            if (barrier_enable && !barrier_active) begin
                target_count <= barrier_count;
                ready_count <= 4'd0;
                barrier_active <= 1'b1;
                release_reg <= 1'b0;
            end else if (barrier_active) begin
                if (pe_ready) begin
                    ready_count <= ready_count + 1'b1;
                end
                
                if (ready_count >= target_count) begin
                    release_reg <= 1'b1;
                    barrier_active <= 1'b0;
                    ready_count <= 4'd0;
                end
            end else begin
                release_reg <= 1'b1;
            end
        end
    end

endmodule
