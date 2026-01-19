$ErrorActionPreference = "Continue"

$files = Get-ChildItem -Path "b:\MyCode\trae\NPU\rtl" -Recurse -File | Where-Object { $_.Extension -eq ".v" }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    $content = $content -replace 'wire \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'wire [15:0] data [0:63]'
    $content = $content -replace 'input wire \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'input wire [15:0] data [0:63]'
    $content = $content -replace 'output wire \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'output wire [15:0] data [0:63]'
    $content = $content -replace 'reg \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'reg [15:0] data [0:63]'
    $content = $content -replace 'output reg \[15:0\] \[PE_ROWS\*PE_COLS-1:0\]', 'output reg [15:0] data [0:63]'
    
    $content = $content -replace 'wire noc_valid_in \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_valid_in [0:63]'
    $content = $content -replace 'wire noc_valid_out \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_valid_out [0:63]'
    $content = $content -replace 'wire noc_ready_in \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_ready_in [0:63]'
    $content = $content -replace 'wire noc_ready_out \[PE_ROWS\*PE_COLS-1:0\]', 'wire noc_ready_out [0:63]'
    $content = $content -replace 'input wire noc_valid_in \[PE_ROWS\*PE_COLS-1:0\]', 'input wire noc_valid_in [0:63]'
    $content = $content -replace 'output wire noc_valid_out \[PE_ROWS\*PE_COLS-1:0\]', 'output wire noc_valid_out [0:63]'
    $content = $content -replace 'output wire noc_ready_in \[PE_ROWS\*PE_COLS-1:0\]', 'output wire noc_ready_in [0:63]'
    $content = $content -replace 'input wire noc_ready_out \[PE_ROWS\*PE_COLS-1:0\]', 'input wire noc_ready_out [0:63]'
    $content = $content -replace 'reg noc_valid_in \[PE_ROWS\*PE_COLS-1:0\]', 'reg noc_valid_in [0:63]'
    $content = $content -replace 'reg noc_valid_out \[PE_ROWS\*PE_COLS-1:0\]', 'reg noc_valid_out [0:63]'
    $content = $content -replace 'reg noc_ready_in \[PE_ROWS\*PE_COLS-1:0\]', 'reg noc_ready_in [0:63]'
    $content = $content -replace 'reg noc_ready_out \[PE_ROWS\*PE_COLS-1:0\]', 'reg noc_ready_out [0:63]'
    
    $content = $content -replace 'wire \[4:0\] router_dest \[PE_ROWS\*PE_COLS-1:0\]', 'wire [4:0] router_dest [0:63]'
    $content = $content -replace 'input wire \[4:0\] router_dest \[PE_ROWS\*PE_COLS-1:0\]', 'input wire [4:0] router_dest [0:63]'
    $content = $content -replace 'wire router_data_in \[PE_ROWS\*PE_COLS-1:0\]', 'wire [15:0] router_data_in [0:63]'
    $content = $content -replace 'wire router_data_out \[PE_ROWS\*PE_COLS-1:0\]', 'wire [15:0] router_data_out [0:63]'
    $content = $content -replace 'input wire router_data_in \[PE_ROWS\*PE_COLS-1:0\]', 'input wire [15:0] router_data_in [0:63]'
    $content = $content -replace 'output wire router_data_out \[PE_ROWS\*PE_COLS-1:0\]', 'output wire [15:0] router_data_out [0:63]'
    $content = $content -replace 'reg router_data_out_reg \[PE_ROWS\*PE_COLS-1:0\]', 'reg [15:0] router_data_out_reg [0:63]'
    $content = $content -replace 'reg router_valid_out_reg \[PE_ROWS\*PE_COLS-1:0\]', 'reg router_valid_out_reg [0:63]'
    $content = $content -replace 'reg router_ready_in_reg \[PE_ROWS\*PE_COLS-1:0\]', 'reg router_ready_in_reg [0:63]'
    
    $content = $content -replace 'for \(i = 0; i < PE_ROWS; i = i \+ 1\)', 'for (i = 0; i < 8; i = i + 1)'
    $content = $content -replace 'for \(j = 0; j < PE_COLS; j = j \+ 1\)', 'for (j = 0; j < 8; j = j + 1)'
    $content = $content -replace 'localparam pe_idx = i \* PE_COLS \+ j', 'localparam pe_idx = i * 8 + j'
    
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Fixed all array declarations in Verilog files" -ForegroundColor Green
