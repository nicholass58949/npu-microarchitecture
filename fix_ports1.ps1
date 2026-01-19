$ErrorActionPreference = "Continue"

$file = "b:\MyCode\trae\NPU\rtl\common\npu_top.v"
$content = Get-Content -Path $file -Raw

$content = $content -replace 'pooling_unit u_pooling_unit \(\s*\.clk\(clk\),\s*\.rst_n\(rst_n\),\s*\.input_data\(pool_input\),\s*\.output_data\(pool_output\),\s*\.pool_type\(pool_type\),\s*\.valid\(pool_valid\),\s*\.ready\(pool_ready\)\s*\);', 'pooling_unit u_pooling_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(pool_input),
        .data_out(pool_output),
        .pool_type(pool_type),
        .valid_in(pool_valid),
        .ready_in(pool_ready),
        .valid_out(pool_valid_out),
        .ready_out(pool_ready_out),
        .kernel_size(2''d2)
    );'

$content = $content -replace 'activation_unit u_activation_unit \(\s*\.clk\(clk\),\s*\.rst_n\(rst_n\),\s*\.input_data\(activation_input\),\s*\.output_data\(activation_output\),\s*\.activation_type\(activation_type\),\s*\.valid\(activation_valid\),\s*\.ready\(activation_ready\)\s*\);', 'activation_unit u_activation_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(activation_input),
        .data_out(activation_output),
        .act_type(activation_type),
        .valid(activation_valid),
        .valid_out(activation_valid_out),
        .ready(activation_ready)
    );'

$content = $content -replace 'batch_normalization u_batch_normalization \(\s*\.clk\(clk\),\s*\.rst_n\(rst_n\),\s*\.input_data\(bn_input\),\s*\.output_data\(bn_output\),\s*\.valid\(bn_valid\),\s*\.ready\(bn_ready\)\s*\);', 'batch_normalization u_batch_normalization (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(bn_input),
        .data_out(bn_output),
        .valid_in(bn_valid),
        .ready_in(bn_ready),
        .valid_out(bn_valid_out),
        .ready_out(bn_ready_out),
        .gamma(16''d1),
        .beta(16''d0),
        .mean(16''d0),
        .variance(16''d1)
    );'

Set-Content -Path $file -Value $content -NoNewline

Write-Host "Fixed pooling, activation, and batch normalization units" -ForegroundColor Green
