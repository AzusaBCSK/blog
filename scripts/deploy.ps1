$HugoRoot = "C:\Users\Wynn\blog"

cd $HugoRoot
Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow

git add .
$Time = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "Update: $Time"
git push origin main

Write-Host "🎉 Success! Blog is deploying." -ForegroundColor Green
Start-Sleep -Seconds 5