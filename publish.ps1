# 

$source = "D:\Obsidian-Vault\Vault\CADT\Publish"
$dest   = "D:\Obsidian-Vault\Site\my-notes-site\content"
$repo   = "D:\Obsidian-Vault\Site\my-notes-site"

Write-Host "Syncing notes..." -ForegroundColor Cyan
robocopy $source $dest /MIR /XD ".obsidian" | Out-Null

Write-Host "Fixing image links..." -ForegroundColor Yellow

Get-ChildItem -Path $dest -Recurse -Filter *.md | ForEach-Object {
    $noteDir = $_.DirectoryName
    $assetsDir = Join-Path $noteDir "assets"

    if (Test-Path $assetsDir) {
        $content = Get-Content $_.FullName -Raw

        Get-ChildItem -Path $assetsDir -File | ForEach-Object {
            $name = $_.Name
            $escapedName = [regex]::Escape($name)

            $content = $content -replace "!\[\[$escapedName\]\]", "![](./assets/$name)"
        }

        Set-Content $_.FullName $content
    }
}

Write-Host "Building Quartz..." -ForegroundColor Green
Set-Location $repo
npx quartz build

Write-Host "Pushing to GitHub..." -ForegroundColor Magenta
git add .
git commit -m "update notes $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push

Write-Host "Done." -ForegroundColor Cyan