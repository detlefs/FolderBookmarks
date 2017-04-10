#
# Debug_FolderBookmarks.ps1
#
Remove-Module FolderBookmark -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\FolderBookmarks.psd1" -Force
Import-FolderBookmark
Get-FolderBookmark