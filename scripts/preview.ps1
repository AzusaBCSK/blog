$SourcePath = "C:\Users\Wynn\Documents\BlogVault\BlogPosts"
$DestPath   = "C:\Users\Wynn\blog\content\post"
$HugoRoot   = "C:\Users\Wynn\blog"
$FontScript = "C:\Users\Wynn\blog\scripts\subset_font.ps1"

Get-Process -Name "hugo" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "🔄 Syncing..." -ForegroundColor Cyan

robocopy $SourcePath $DestPath /MIR /FFT /Z /XD ".obsidian" ".git" /NP /NFL /NDL /NJH /NJS | Out-Null

Set-Location $HugoRoot

if (Test-Path $FontScript) {
    Write-Host "🔠 Subsetting fonts..." -ForegroundColor Cyan
    & $FontScript
} else {
    Write-Host "⚠️ Font script not found!" -ForegroundColor Yellow
}

Write-Host "✅ Done!" -ForegroundColor Green

Start-Process "hugo" -ArgumentList "server -D --navigateToChanged" -NoNewWindow