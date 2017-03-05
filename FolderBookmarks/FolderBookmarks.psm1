<#
	Module FolderBookmarks

	The module provides functions to manage and use bookmarks that point to folders.
	Bookmarks can be created, changed and removed. Each change is immediately stored in the
	user's CliXml file.
	The CliXml file in the user's profile can be imported via a function. It's advised to
	perform the import in the user's $profile script so the bookmarks are available when a
	new PowerShell session is started.

	Version history
	---------------
	v1.0.2	- Details for publishing
	v1.0.1	- Implemented support for -WhatIf and -Confirm in Set-FolderBookmark and Remove-FolderBookmark
	v1.0.0	- Initial version

	Apache License
	Version 2.0, January 2004
	http://www.apache.org/licenses/
#>

$Script:folderBMs = @{}
$Script:folderBMPath = Join-Path (Split-Path -Parent $profile) .folderBM.clixml

function Set-FolderBookmark {
	<#
	.SYNOPSIS
		Stores a folder ath to a named bookmark
	.DESCRIPTION
		The given path is stored to a bookmark that can be used with Get-FolderBookmark

		The list of bookmarks is exported to the user profile using Export-FolderBookmarks
	.PARAMETER Name
		Mandatory: yes, Alias(es): n
	.PARAMETER Path
		Mandatory: no, Alias(es): p
		Specifies the path to be stored to the bookmark. If not specified, ".\" is used
	.EXAMPLE
		Set-FolderBookmark -Name Sys32 -Path C:\Windows\System32

		Stores a bookmark with the name Sys32 that points to the folder C:\Windows\System32
	.EXAMPLE
		cd C:\Projects\PowerShell\ModuleDev\Test1
		Set-FolderBookmark Test1

		Stores a bookmark with the name Test1 that points to the current folder
	.NOTES
		Version history
		---------------
		v1.0.0	- Initial version
	#>

	[CmdletBinding(SupportsShouldProcess=$true)]
	param (
		[Parameter(Position=0, Mandatory=$true)][Alias("n")][string]$Name,
		[Parameter(Position=1)][Alias("p")][string]$Path = $(Get-Location).Path
	)

	if (!(Get-Item $Path).PSIsContainer) {
		Write-Error "$Path is not a folder." -Category InvalidData -RecommendedAction "Please provide a folder path."
		return
	}

	if ($PSCmdlet.ShouldProcess($Name, "Set FolderBookmark")) {
		if ($Script:folderBMs.ContainsKey($Name)) {
			#Update existing entry
			$Script:folderBMs.Set_Item($Name, $Path)
		}
		else {
			#Add new entry to collection
			$Script:folderBMs.Add($Name, $Path)
		}
		Export-FolderBookmark
	}
}
New-Alias -Name setbm -Value Set-FolderBookmark
New-Alias -Name bookmark -Value Set-FolderBookmark

function Use-FolderBookmark {
	<#
	.SYNOPSIS
		Retrieves the folder from a named bookmark and sets current location to the folder
	.PARAMETER Name
		Mandatory: yes, Alias(es): n
	.EXAMPLE
		Use-FolderBookmark -Name Sys32

		Changes the current location to folder stored as bookmark Sys32
	.EXAMPLE
		goto test1

		Changes the current location to folder stored as bookmark test1
	.NOTES
		Version history
		---------------
		v1.0.0	- Initial version
	#>

	[CmdletBinding()]
	param (
		[Parameter(Position=0, Mandatory=$true)][Alias("n")][string]$Name
	)

	Set-Location $Script:folderBMs.Get_Item($Name)
}
New-Alias -Name goto -Value Use-FolderBookmark
New-Alias -Name getbm -Value Use-FolderBookmark

function Remove-FolderBookmark {
	<#
	.SYNOPSIS
		Removes the named bookmark from the bookmark-list
	.DESCRIPTION
		Removes the bookmark with specified name from the bookmark-list.

		The list of bookmarks is exported to the user profile using Export-FolderBookmarks
	.PARAMETER Name
		Mandatory: yes, Alias(es): n
	.EXAMPLE
		Use-FolderBookmark -Name Sys32

		Changes the current location to folder stored as bookmark Sys32
	.EXAMPLE
		goto test1

		Changes the current location to folder stored as bookmark test1
	.NOTES
		Version history
		---------------
		v1.0.1	- Added support for pipeline and multiple names
		v1.0.0	- Initial version
	#>

	[CmdletBinding(SupportsShouldProcess=$true)]
	param (
		[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][Alias("n")][string[]]$Name
	)

	Begin { }

	Process {
		foreach ($n in $Name) {
			if ($PSCmdlet.ShouldProcess($n, "Remove folder bookmark")) {
				$Script:folderBMs.Remove($n)
				Write-Verbose "Removed bookmark $n"
			}
		}
	}

	End {
		if ($PSCmdlet.ShouldProcess("*", "Export folder bookmark")) {
			Export-FolderBookmark
		}
	}
}
New-Alias -Name rembm -Value Remove-FolderBookmark
New-Alias -Name unbookmark -Value Remove-FolderBookmark

function Get-FolderBookmark {
	<#
	.SYNOPSIS
		Lists the folder bookmarks
	.EXAMPLE
		Get-FolderBookmark

		Lists all bookmark
	.NOTES
		Version history
		---------------
		v1.0.0	- Initial version
	#>

	$Script:folderBMs.GetEnumerator() | Sort-Object Name
}
New-Alias -Name listbm -Value Get-FolderBookmark

function Export-FolderBookmark {
	<#
	.SYNOPSIS
		Exports the folder bookmarks to the user's profile folder
	.DESCRIPTION
		Exports the folder bookmarks to the user's profile folder with the name .folderBM.xml
	.EXAMPLE
		Export-FolderBookmark

		Exports all bookmarks to file in current users profile
	.NOTES
		Version history
		---------------
		v1.0.0	- Initial version
	#>

	$Script:folderBMs | Export-Clixml -Path $Script:folderBMPath -Encoding UTF8 -Force
}
New-Alias -Name expbm -Value Export-FolderBookmark

function Import-FolderBookmark {
	<#
	.SYNOPSIS
		Imports the folder bookmarks from the user's profile folder
	.DESCRIPTION
		Imports the folder bookmarks from the user's profile file with the name .folderBM.xml
		Existing bookmarks in memory will be overwritten

		To automatically import the bookmarks into each user session, it's easy to add the command to
		the users profile script.
	.EXAMPLE
		Import-FolderBookmark

		Imports all bookmarks from file
	.NOTES
		Version history
		---------------
		v1.0.0	- Initial version
	#>
	if (Test-Path $Script:folderBMPath) {
		$Script:folderBMs = Import-Clixml -Path $Script:folderBMPath
	}
}
New-Alias -Name impbm -Value Import-FolderBookmark