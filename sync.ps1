$source = "D:\Obsidian-Vault\Vault\CADT\Publish\*"
$destination = "D:\Obsidian-Vault\Site\my-notes-site\content"

Get-ChildItem $destination -Force | Remove-Item -Recurse -Force
Copy-Item $source $destination -Recurse

Write-Host "Notes synced successfully."
npx quartz build --serve