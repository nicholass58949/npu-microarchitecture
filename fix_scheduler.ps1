$ErrorActionPreference = "Continue"

$file = "b:\MyCode\trae\NPU\rtl\control\instruction_scheduler.v"
$content = Get-Content -Path $file -Raw

$content = $content -replace 'if \(current_pe < PE_ROWS\*PE_COLS - 1\)', 'if (current_pe < 6''d63)'
$content = $content -replace 'if \(current_pe < 8\*8 - 1\)', 'if (current_pe < 6''d63)'

Set-Content -Path $file -Value $content -NoNewline

Write-Host "Fixed instruction_scheduler.v" -ForegroundColor Green
