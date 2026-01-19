$ErrorActionPreference = "Continue"

$files = Get-ChildItem -Path "b:\MyCode\trae\NPU\rtl" -Recurse -File | Where-Object { $_.Extension -eq ".v" }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    $content = $content -replace 'input activation_type_t act_type', 'input wire [1:0] act_type'
    $content = $content -replace 'input pool_type_t pool_type', 'input wire [1:0] pool_type'
    
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Fixed type declarations in Verilog files" -ForegroundColor Green
