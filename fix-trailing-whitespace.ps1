# Fix trailing whitespace in PowerShell files
Write-Host "Fixing trailing whitespace in PowerShell files..." -ForegroundColor Green

$files = Get-ChildItem -Path "PowerShell/VideoFunctions/" -Filter "*.ps1" -Recurse

$totalFixed = 0
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalLength = $content.Length
    
    # Remove trailing whitespace from each line
    $lines = $content -split "`n"
    $fixedLines = $lines | ForEach-Object { $_.TrimEnd() }
    $fixedContent = $fixedLines -join "`n"
    
    if ($fixedContent.Length -ne $originalLength) {
        Set-Content -Path $file.FullName -Value $fixedContent -NoNewline
        $totalFixed++
        Write-Host "Fixed: $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host "`nFixed trailing whitespace in $totalFixed files." -ForegroundColor Green 