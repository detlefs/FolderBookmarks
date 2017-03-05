<#
	Manifest for module FolderBookmarks

	The module provides functions to manage and use bookmarks that point to folders.
	Bookmarks can be created, changed and removed. Each change is immediately stored in the
	user's CliXml file.
	The CliXml file in the user's profile can be imported via a function. It's advised to
	perform the import in the user's $profile script so the bookmarks are available when a
	new PowerShell session is started.

	Version history
	---------------
	v1.0.1	- Implemented support for -WhatIf and -Confirm in Set-FolderBookmark and Remove-FolderBookmark
	v1.0.0	- Initial version

	Apache License
	Version 2.0, January 2004
	http://www.apache.org/licenses/
#>

@{
# Script module or binary module file associated with this manifest.
RootModule = 'FolderBookmarks.psm1'

# Version number of this module.
ModuleVersion = '1.0.1'

# ID used to uniquely identify this module
GUID = 'bd98b402-156f-40a2-8d50-892f65d96dd2'

# Author of this module
Author = 'Detlef Schneider'

# Company or vendor of this module
CompanyName = 'Schneide-r.de'

# Copyright statement for this module
Copyright = '(c) 2017 by Detlef Schneider.'

# Description of the functionality provided by this module
Description = 'The module provides functions to manage and use bookmarks that point to folders.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = 'Set-FolderBookmark', 'Use-FolderBookmark', 'Remove-FolderBookmark',
	'Get-FolderBookmark', 'Export-FolderBookmark', 'Import-FolderBookmark'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = 'setbm', 'bookmark', 'goto', 'getbm', 'rembm', 'unbookmark', 'listbm', 'expbm', 'impbm'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''
}