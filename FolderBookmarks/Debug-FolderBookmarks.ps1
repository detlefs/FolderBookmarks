#
# Debug_FolderBookmarks.ps1
#
Remove-Module FolderBookmark -Force -ErrorAction SilentlyContinue
Import-Module FolderBookmark -Force

setbm -Name one -Path C:\Temp
setbm -Name two -Path C:\Temp

Use-FolderBookmark -Name git