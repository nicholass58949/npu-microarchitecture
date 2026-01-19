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
            input_ready_count = 6'd0;
            weight_ready_count = 6'd0;
            
            for (k = 0; k < 64; k = k + 1) begin
                if (pe_input_ready[k]) begin
                    input_ready_count = input_ready_count + 1'b1;
                end
                if (pe_weight_ready[k]) begin
                    weight_ready_count = weight_ready_count + 1'b1;
                end
            end
            
            if (input_ready_count == 6'd64 && weight_ready_count == 6'd64) begin
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