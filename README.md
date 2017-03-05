# FolderBookmarks
Module provides functions to manage and use folder bookmarks in PowerShell.

The set bookmarks are automatically stored in a file `.folderBM.clixml` in the user's profile path (normally `C:\Users\<username>\Documents\WindowsPowerShell`).

The module is provided under the Apache License Version 2.0. See http://www.apache.org/licenses/ for more details.

**Latest version: 1.0.1**

## Available functions
#### `Set-FolderBookmark -Name [name] -Path [C:\path\to\folder\]`
The specified path is stored to a bookmark that can be used with `Get-FolderBookmark`.
The list of bookmarks is exported to the user profile using `Export-FolderBookmark`.

Alias(es): `setbm`, `bookmark`

#### `Use-FolderBookmark -Name [name]`
Retrieves the folder from a named bookmark and sets current location to the folder.

Alias(es): `goto`, `getbm`

#### `Remove-FolderBookmark -Name [name]`
Removes the bookmark with specified name from the bookmark-list.
The list of bookmarks is exported to the user profile using `Export-FolderBookmark`.

Alias(es): `rmbm`, `unbookmark`

#### `Get-FolderBookmark`
Lists the folder bookmarks

Alias(es): `listbm`

#### `Export-FolderBookmark`
Exports the folder bookmarks to the user's profile folder with the name .folderBM.clixml

Alias(es): `expbm`

#### `Import-FolderBookmark`
Imports the folder bookmarks from the user's profile file with the name .folderBM.clixml.
Existing bookmarks in memory will be overwritten.

To automatically import the bookmarks into each user session, it's advised to add the command to
the users profile script.

Alias(es): `impbm`

## Knowledge
The bookmarks are stored to the user's profile path into a file with name `.folderBM.clixml`.
To load the bookmarks automatically on dtsrtup of a new session, I suggest to add the `Import-FolderBookmark`
call in your `$profile` (normally `C:\Users\detlefs\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`).
