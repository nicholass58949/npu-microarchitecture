$ErrorActionPreference = "Continue"

$file = "b:\MyCode\trae\NPU\rtl\common\npu_top.v"
$content = Get-Content -Path $file -Raw

$content = $content -replace 'wire \[15:0\] pe_array_input \[PE_ROWS\*PE_COLS-1:0\]', 'wire [15:0] pe_array_input [0:63]'
$content = $content -replace 'input wire \[15:0\] pe_array_output \[PE_ROWS\*PE_COLS-1:0\]', 'input wire [15:0] pe_array_output [0:63]'
$content = $content -replace 'wire \[15:0\] noc_data_in \[PE_ROWS\*PE_COLS-1:0\]', 'wire [15:0] noc_data_in [0:63]'
$content = $content -replace 'wire \[15:0\] noc_data_out \[PE_ROWS\*PE_COLS-1:0\]', 'wire [15:0] noc_data_out [0:63]'
$content = $content -replace 'wire noc_valid_in \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_valid_in [0:63]'
$content = $content -replace 'wire noc_valid_out \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_valid_out [0:63]'
$content = $content -replace 'wire noc_ready_in \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_ready_in [0:63]'
$content = $content -replace 'wire noc_ready_out \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_ready_out [0:63]'

Set-Content -Path $file -Value $content -NoNewline

Write-Host "Fixed npu_top.v array declarations" -ForegroundColor Green
