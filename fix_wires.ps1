$ErrorActionPreference = "Continue"

$files = Get-ChildItem -Path "b:\MyCode\trae\NPU\rtl" -Recurse -File | Where-Object { $_.Extension -eq ".v" }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    $content = $content -replace 'wire \[DATA_WIDTH-1:0\]', 'wire [15:0]'
    $content = $content -replace 'input wire \[DATA_WIDTH-1:0\]', 'input wire [15:0]'
    $content = $content -replace 'output wire \[DATA_WIDTH-1:0\]', 'output wire [15:0]'
    $content = $content -replace 'reg \[DATA_WIDTH-1:0\]', 'reg [15:0]'
    $content = $content -replace 'output reg \[DATA_WIDTH-1:0\]', 'output reg [15:0]'
    $content = $content -replace 'input reg \[DATA_WIDTH-1:0\]', 'input reg [15:0]'
    
    $content = $content -replace 'wire \[ADDR_WIDTH-1:0\]', 'wire [31:0]'
    $content = $content -replace 'input wire \[ADDR_WIDTH-1:0\]', 'input wire [31:0]'
    $content = $content -replace 'output wire \[ADDR_WIDTH-1:0\]', 'output wire [31:0]'
    $content = $content -replace 'reg \[ADDR_WIDTH-1:0\]', 'reg [31:0]'
    $content = $content -replace 'output reg \[ADDR_WIDTH-1:0\]', 'output reg [31:0]'
    $content = $content -replace 'input reg \[ADDR_WIDTH-1:0\]', 'input reg [31:0]'
    
    $content = $content -replace 'wire \[MAC_WIDTH-1:0\]', 'wire [31:0]'
    $content = $content -replace 'input wire \[MAC_WIDTH-1:0\]', 'input wire [31:0]'
    $content = $content -replace 'output wire \[MAC_WIDTH-1:0\]', 'output wire [31:0]'
    $content = $content -replace 'reg \[MAC_WIDTH-1:0\]', 'reg [31:0]'
    
    $content = $content -replace 'wire \[ACC_WIDTH-1:0\]', 'wire [39:0]'
    $content = $content -replace 'input wire \[ACC_WIDTH-1:0\]', 'input wire [39:0]'
    $content = $content -replace 'output wire \[ACC_WIDTH-1:0\]', 'output wire [39:0]'
    $content = $content -replace 'reg \[ACC_WIDTH-1:0\]', 'reg [39:0]'
    
    $content = $content -replace 'wire \[CHANNEL_WIDTH-1:0\]', 'wire [7:0]'
    $content = $content -replace 'input wire \[CHANNEL_WIDTH-1:0\]', 'input wire [7:0]'
    $content = $content -replace 'output wire \[CHANNEL_WIDTH-1:0\]', 'output wire [7:0]'
    $content = $content -replace 'reg \[CHANNEL_WIDTH-1:0\]', 'reg [7:0]'
    
    $content = $content -replace '\{DATA_WIDTH\{1''b0\}\}', '{16{1''b0}}'
    $content = $content -replace '\{ADDR_WIDTH\{1''b0\}\}', '{32{1''b0}}'
    $content = $content -replace '\{MAC_WIDTH\{1''b0\}\}', '{32{1''b0}}'
    $content = $content -replace '\{ACC_WIDTH\{1''b0\}\}', '{40{1''b0}}'
    $content = $content -replace '\{CHANNEL_WIDTH\{1''b0\}\}', '{8{1''b0}}'
    
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Fixed all parameterized wire declarations in Verilog files" -ForegroundColor Green
