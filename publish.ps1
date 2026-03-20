$source = "D:\Obsidian-Vault\Vault\CADT\Publish"
$dest   = "D:\Obsidian-Vault\Site\my-notes-site\content\Publish"
$repo   = "D:\Obsidian-Vault\Site\my-notes-site"

Write-Host "[1/3]Syncing notes..." -ForegroundColor Cyan
robocopy $source $dest /MIR /XD ".obsidian" | Out-Null

Write-Host "[2/3]Building Quartz..." -ForegroundColor Yellow
Set-Location $repo
npx quartz build

Write-Host "[3/3]Pushing to GitHub..." -ForegroundColor Green
git add .
git commit -m "update notes $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push

Write-Host "Done, publishing succesful :p" -ForegroundColor Magenta