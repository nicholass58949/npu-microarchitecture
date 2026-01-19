$ErrorActionPreference = "Continue"

$files = Get-ChildItem -Path "b:\MyCode\trae\NPU\rtl" -Recurse -File | Where-Object { $_.Extension -eq ".v" }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    $content = $content -replace 'wire \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'wire [15:0] pe_input [0:63]'
    $content = $content -replace 'output wire \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'output wire [15:0] pe_output [0:63]'
    $content = $content -replace 'input wire \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'input wire [15:0] pe_input [0:63]'
    $content = $content -replace 'wire \[15:0\] \[63:0\]', 'wire [15:0] data [0:63]'
    $content = $content -replace 'output wire \[15:0\] \[63:0\]', 'output wire [15:0] data [0:63]'
    $content = $content -replace 'input wire \[15:0\] \[63:0\]', 'input wire [15:0] data [0:63]'
    
    $content = $content -replace 'wire \[31:0\] \[63:0\]', 'wire [31:0] data [0:63]'
    $content = $content -replace 'output wire \[31:0\] \[63:0\]', 'output wire [31:0] data [0:63]'
    $content = $content -replace 'input wire \[31:0\] \[63:0\]', 'input wire [31:0] data [0:63]'
    
    $content = $content -replace 'wire \[39:0\] \[63:0\]', 'wire [39:0] data [0:63]'
    $content = $content -replace 'output wire \[39:0\] \[63:0\]', 'output wire [39:0] data [0:63]'
    $content = $content -replace 'input wire \[39:0\] \[63:0\]', 'input wire [39:0] data [0:63]'
    
    $content = $content -replace 'wire \[7:0\] \[63:0\]', 'wire [7:0] data [0:63]'
    $content = $content -replace 'output wire \[7:0\] \[63:0\]', 'output wire [7:0] data [0:63]'
    $content = $content -replace 'input wire \[7:0\] \[63:0\]', 'input wire [7:0] data [0:63]'
    
    $content = $content -replace 'wire noc_valid_in \[63:0\]', 'wire noc_valid_in [0:63]'
    $content = $content -replace 'wire noc_valid_out \[63:0\]', 'wire noc_valid_out [0:63]'
    $content = $content -replace 'wire noc_ready_in \[63:0\]', 'wire noc_ready_in [0:63]'
    $content = $content -replace 'wire noc_ready_out \[63:0\]', 'wire noc_ready_out [0:63]'
    $content = $content -replace 'input wire noc_valid_in \[63:0\]', 'input wire noc_valid_in [0:63]'
    $content = $content -replace 'output wire noc_valid_out \[63:0\]', 'output wire noc_valid_out [0:63]'
    $content = $content -replace 'output wire noc_ready_in \[63:0\]', 'output wire noc_ready_in [0:63]'
    $content = $content -replace 'input wire noc_ready_out \[63:0\]', 'input wire noc_ready_out [0:63]'
    
    $content = $content -replace 'wire \[7:0\] \[7:0\]', 'wire [7:0] data [0:7]'
    $content = $content -replace 'output wire \[7:0\] \[7:0\]', 'output wire [7:0] data [0:7]'
    $content = $content -replace 'input wire \[7:0\] \[7:0\]', 'input wire [7:0] data [0:7]'
    
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Fixed all array declarations in Verilog files" -ForegroundColor Green
