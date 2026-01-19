$ErrorActionPreference = "Continue"

$files = Get-ChildItem -Path "b:\MyCode\trae\NPU\rtl" -Recurse -File | Where-Object { $_.Extension -eq ".v" }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    $content = $content -replace 'DATA_WIDTH', "16"
    $content = $content -replace 'ADDR_WIDTH', "32"
    $content = $content -replace 'MAC_WIDTH', "32"
    $content = $content -replace 'ACC_WIDTH', "40"
    $content = $content -replace 'BUFFER_SIZE', "1024"
    $content = $content -replace 'CHANNEL_WIDTH', "8"
    
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

Write-Host "Fixed all width parameters" -ForegroundColor Green
