$ErrorActionPreference = "Continue"

$files = Get-ChildItem -Path "b:\MyCode\trae\NPU\rtl" -Recurse -File | Where-Object { $_.Extension -eq ".v" }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    $content = $content -replace '\[PE_ROWS\*PE_COLS-1:0\]', '[0:63]'
    $content = $content -replace 'PE_ROWS\*PE_COLS', '8*8'
    $content = $content -replace 'PE_ROWS', '8'
    $content = $content -replace 'PE_COLS', '8'
    
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Fixed all PE_ROWS and PE_COLS references" -ForegroundColor Green
