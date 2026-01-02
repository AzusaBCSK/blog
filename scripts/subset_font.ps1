# =================配置区域=================
# 1. 自动获取当前脚本所在目录 (即 C:\Users\Wynn\blog\scripts)
$ScriptDir = $PSScriptRoot

# 2. 推算 Hugo 根目录 (即 C:\Users\Wynn\blog)
$HugoRoot  = Split-Path $ScriptDir -Parent

# 3. 定义工具的绝对路径 (基于你的 dir 结构)
$HbSubsetPath   = Join-Path $ScriptDir "harfbuzz\hb-subset.exe"
$Woff2DecPath   = Join-Path $ScriptDir "woff2\woff2_decompress.exe"
$Woff2CompPath  = Join-Path $ScriptDir "woff2\woff2_compress.exe"

# 4. 定义数据路径
$FontDir     = Join-Path $HugoRoot "static\fonts"
$SourceWoff2 = Join-Path $FontDir "XiaolaiSC-Regular.woff2"
$TempTTF     = Join-Path $FontDir "XiaolaiSC-Regular.ttf"
$TargetFont  = Join-Path $FontDir "XiaolaiSC-Regular-subset.woff2"
$CharFile    = Join-Path $HugoRoot "characters.txt"
$SubsetTTF   = Join-Path $FontDir "temp_subset.ttf"

# =================检查环境=================
# 确保所有工具都在
if (-not (Test-Path $HbSubsetPath))  { throw "❌ 找不到 $HbSubsetPath" }
if (-not (Test-Path $Woff2DecPath))  { throw "❌ 找不到 $Woff2DecPath" }
if (-not (Test-Path $Woff2CompPath)) { throw "❌ 找不到 $Woff2CompPath" }
if (-not (Test-Path $SourceWoff2))   { throw "❌ 找不到源字体文件: $SourceWoff2" }

# =================开始执行=================

Write-Host "🏗️  Hugo Building (Generating HTML)..." -ForegroundColor Cyan
# 切换到 Hugo 根目录执行构建，确保 public 生成正确
Push-Location $HugoRoot
hugo --quiet
Pop-Location

Write-Host "🔍 Extracting Characters..." -ForegroundColor Cyan
$HashSet = [System.Collections.Generic.HashSet[char]]::new()
Get-ChildItem -Path (Join-Path $HugoRoot "public") -Recurse -Filter "*.html" | ForEach-Object {
    $Content = [System.IO.File]::ReadAllText($_.FullName)
    foreach ($Char in $Content.ToCharArray()) {
        if (-not [System.String]::IsNullOrWhiteSpace($Char)) { [void]$HashSet.Add($Char) }
    }
}
$AllChars = -join ($HashSet)
[System.IO.File]::WriteAllText($CharFile, $AllChars, [System.Text.Encoding]::UTF8)

Write-Host "🔓 Decompressing WOFF2..." -ForegroundColor Yellow
if (Test-Path $TempTTF) { Remove-Item $TempTTF -Force }

# 调用 woff2_decompress (使用绝对路径)
$Output = & $Woff2DecPath $SourceWoff2 2>&1
if (-not (Test-Path $TempTTF)) {
    Write-Host "❌ 解压失败: $Output" -ForegroundColor Red
    throw "无法生成 TTF 文件"
}

Write-Host "⚡ HarfBuzz Subsetting..." -ForegroundColor Yellow
# 调用 hb-subset (使用绝对路径)
# 注意：HarfBuzz 需要依赖同目录下的 DLL，PowerShell 调用 exe 时通常能自动识别同目录 dll
$HbOutput = & $HbSubsetPath $TempTTF --output-file=$SubsetTTF --text-file=$CharFile 2>&1

if (-not (Test-Path $SubsetTTF)) { 
    Write-Host "❌ 裁剪失败: $HbOutput" -ForegroundColor Red
    throw "HarfBuzz 未生成文件" 
}

Write-Host "📦 Compressing..." -ForegroundColor Yellow
# 调用 woff2_compress (使用绝对路径)
$CompOutput = & $Woff2CompPath $SubsetTTF 2>&1

# woff2_compress 会在同目录下生成 .woff2，我们需要把它移到目标位置
$GeneratedWoff2 = $SubsetTTF -replace "\.ttf$", ".woff2"

if (Test-Path $GeneratedWoff2) {
    Move-Item $GeneratedWoff2 $TargetFont -Force
    Write-Host "✅ Success! Font generated: $TargetFont" -ForegroundColor Green
} else {
    Write-Host "❌ 压缩失败: $CompOutput" -ForegroundColor Red
}

# =================清理垃圾=================
Remove-Item $TempTTF -ErrorAction SilentlyContinue
Remove-Item $SubsetTTF -ErrorAction SilentlyContinue
Remove-Item $CharFile -ErrorAction SilentlyContinue