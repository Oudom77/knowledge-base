$source = "D:\Obsidian-Vault\Vault\CADT\Publish"
$dest   = "D:\Obsidian-Vault\Site\my-notes-site\content"
$repo   = "D:\Obsidian-Vault\Site\my-notes-site"

Write-Host "Syncing notes..." -ForegroundColor Cyan
robocopy $source $dest /MIR /XD ".obsidian" | Out-Null

Write-Host "Fixing image paths for Quartz..." -ForegroundColor Yellow

Get-ChildItem -Path $dest -Recurse -Filter *.md | ForEach-Object {
    $file = $_.FullName
    $folder = $_.DirectoryName
    $relativeFolder = $folder.Substring($dest.Length).Replace("\", "/").TrimStart("/")

    $content = Get-Content $file -Raw

    # Convert Obsidian wikilink image embeds like ![[assets/file.png]]
    $content = [regex]::Replace($content, '!\[\[(assets\/([^\]]+))\]\]', {
        param($match)
        $imgPath = $match.Groups[1].Value
        "![](/$relativeFolder/$imgPath)"
    })

    # Convert markdown relative image links like ![](assets/file.png)
    $content = [regex]::Replace($content, '!\[\]\((assets\/([^)]+))\)', {
        param($match)
        $imgPath = $match.Groups[1].Value
        "![](/$relativeFolder/$imgPath)"
    })

    # Convert markdown relative image links like ![](./assets/file.png)
    $content = [regex]::Replace($content, '!\[\]\(\.\/(assets\/([^)]+))\)', {
        param($match)
        $imgPath = $match.Groups[1].Value
        "![](/$relativeFolder/$imgPath)"
    })

    Set-Content $file $content
}

Write-Host "Building Quartz..." -ForegroundColor Green
Set-Location $repo
npx quartz build

Write-Host "Pushing to GitHub..." -ForegroundColor Magenta
git add .
git commit -m "update notes $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push

Write-Host "Done." -ForegroundColor Cyan