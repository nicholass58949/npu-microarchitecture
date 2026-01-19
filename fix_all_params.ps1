$ErrorActionPreference = "Continue"

$files = Get-ChildItem -Path "b:\MyCode\trae\NPU\rtl" -Recurse -File | Where-Object { $_.Extension -eq ".v" }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    $content = $content -replace 'ACT_NONE', "2'd0"
    $content = $content -replace 'ACT_RELU', "2'd1"
    $content = $content -replace 'ACT_RELU6', "2'd2"
    $content = $content -replace 'ACT_SIGMOID', "2'd3"
    
    $content = $content -replace 'POOL_NONE', "2'd0"
    $content = $content -replace 'POOL_MAX', "2'd1"
    $content = $content -replace 'POOL_AVG', "2'd2"
    $content = $content -replace 'POOL_GLOBAL', "2'd3"
    
    $content = $content -replace 'OP_CONV', "3'd0"
    $content = $content -replace 'OP_MATMUL', "3'd1"
    $content = $content -replace 'OP_POOL', "3'd2"
    $content = $content -replace 'OP_ACTIVATION', "3'd3"
    $content = $content -replace 'OP_BATCHNORM', "3'd4"
    $content = $content -replace 'OP_RESHAPE', "3'd5"
    $content = $content -replace 'OP_CONCAT', "3'd6"
    $content = $content -replace 'OP_NOP', "3'd7"
    
    $content = $content -replace 'MEM_IDLE', "3'd0"
    $content = $content -replace 'MEM_READ', "3'd1"
    $content = $content -replace 'MEM_WRITE', "3'd2"
    $content = $content -replace 'MEM_WAIT', "3'd3"
    $content = $content -replace 'MEM_DONE', "3'd4"
    $content = $content -replace 'MEM_ERROR', "3'd5"
    
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Fixed all parameter references" -ForegroundColor Green
