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
	v1.0.5	- Implemented Test-FolderBookmark function
	v1.0.4	- Implemented dynamic parameter validation for Use-FolderBookmark and Remove-FolderBookmark
	v1.0.3	- Changed/Added some aliases, added Export-ModuleMember for Posh4 compatibility
	v1.0.2	- Details for publishing
	v1.0.1	- Implemented support for -WhatIf and -Confirm in Set-FolderBookmark and Remove-FolderBookmark
	v1.0.0	- Initial version

	Apache License
	Version 2.0, January 2004
	http://www.apache.org/licenses/
#>

# Global script variables
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
		[Parameter(Position=0, Mandatory=$true, HelpMessage="Enter the name of a bookmark")][Alias("n")][string]$Name,
		[Parameter(Position=1, HelpMessage="Enter the folder path, the bookmark will point to")][Alias("p")]
		[ValidateScript({
			if ((Get-Item $_).PSIsContainer) {
				$true
			}
			else {
				throw "$_ is not a folder."
			}
		})]
		[string]$Path = $(Get-Location).Path
	)

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
		Name of the bookmark to use
	.EXAMPLE
		Use-FolderBookmark -Name Sys32

		Changes the current location to folder stored as bookmark Sys32
	.EXAMPLE
		goto test1

		Changes the current location to folder stored as bookmark test1
	.NOTES
		Version history
		---------------
		v1.0.1	- Implemented dynamic parameter validation
		v1.0.0	- Initial version
	#>

	[CmdletBinding()]
	param (
		#[Parameter(Position=0, Mandatory=$true)][Alias("n")][string]$Name
	)
	DynamicParam {
		$values = (Get-FolderBookmark).Name
		New-DynamicParam -Name Name -ValidateSet $values -Position 0 -Mandatory -HelpMessage "Enter the name of a bookmark" -Alias n
	}

	begin {
		$Name = $PSBoundParameters.Name
	}

	process {
		Set-Location $Script:folderBMs.Get_Item($Name)
	}
}
New-Alias -Name goto -Value Use-FolderBookmark
New-Alias -Name gobm -Value Use-FolderBookmark
New-Alias -Name go -Value Use-FolderBookmark

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
		#[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][Alias("n")][string[]]$Name
	)
	DynamicParam {
		$values = (Get-FolderBookmark).Name
		New-DynamicParam -Name Name -ValidateSet $values -Position 0 -Mandatory -ValueFromPipeline -ValueFromPipelineByPropertyName -Type array -HelpMessage "Enter the name of a bookmark" -Alias n
	}

	Begin {
		$Name = $PSBoundParameters.Name
	}

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

		Lists all bookmarks
	.NOTES
		Version history
		---------------
		v1.0.0	- Initial version
	#>

	$Script:folderBMs.GetEnumerator() | Sort-Object Name
}
New-Alias -Name getbm -Value Get-FolderBookmark
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

function Test-FolderBookmark {
	<#
	.SYNOPSIS
		Tests if a specified path is stored in the bookmark list
	.DESCRIPTION
		The function tests, if the specified path is stored in the bookmark list. If the path is found in the list, the function returns $true. Otherwise $false is returned
	.EXAMPLE
		Test-FolderBookmark -Path C:\Windows\System32

		Returns $true or $false
	.NOTES
		Version history
		---------------
		v1.0.0	- Initial version
	#>

	[CmdletBinding()]
	param (
		[Parameter(Position=0, HelpMessage="Specify a folder path to test")][Alias("p")]
		[ValidateScript({
			if ((Get-Item $_).PSIsContainer) {
				$true
			}
			else {
				throw "$_ is not a folder."
			}
		})]
		[string]$Path = $(Get-Location).Path
	)

	$Script:folderBMs.ContainsValue($Path)
}
New-Alias -Name testbm -Value Test-FolderBookmark

#region Helper functions
# New-DynamicParam is downloaded from https://github.com/RamblingCookieMonster/PowerShell/blob/master/New-DynamicParam.ps1
# Two additional parameters added: ValueFromPipeline, ValueFromRemainingArguments
Function New-DynamicParam {
<#
    .SYNOPSIS
        Helper function to simplify creating dynamic parameters

    .DESCRIPTION
        Helper function to simplify creating dynamic parameters

        Example use cases:
            Include parameters only if your environment dictates it
            Include parameters depending on the value of a user-specified parameter
            Provide tab completion and intellisense for parameters, depending on the environment

        Please keep in mind that all dynamic parameters you create will not have corresponding variables created.
           One of the examples illustrates a generic method for populating appropriate variables from dynamic parameters
           Alternatively, manually reference $PSBoundParameters for the dynamic parameter value

    .NOTES
        Credit to http://jrich523.wordpress.com/2013/05/30/powershell-simple-way-to-add-dynamic-parameters-to-advanced-function/
            Added logic to make option set optional
            Added logic to add RuntimeDefinedParameter to existing DPDictionary
            Added a little comment based help

        Credit to BM for alias and type parameters and their handling

    .PARAMETER Name
        Name of the dynamic parameter

    .PARAMETER Type
        Type for the dynamic parameter.  Default is string

    .PARAMETER Alias
        If specified, one or more aliases to assign to the dynamic parameter

    .PARAMETER ValidateSet
        If specified, set the ValidateSet attribute of this dynamic parameter

    .PARAMETER Mandatory
        If specified, set the Mandatory attribute for this dynamic parameter

    .PARAMETER ParameterSetName
        If specified, set the ParameterSet attribute for this dynamic parameter

    .PARAMETER Position
        If specified, set the Position attribute for this dynamic parameter

    .PARAMETER ValueFromPipelineByPropertyName
        If specified, set the ValueFromPipelineByPropertyName attribute for this dynamic parameter

	.PARAMETER ValueFromPipeline
        If specified, set the ValueFromPipeline attribute for this dynamic parameter

	.PARAMETER ValueFromRemainingArguments
        If specified, set the ValueFromRemainingArguments attribute for this dynamic parameter

    .PARAMETER HelpMessage
        If specified, set the HelpMessage for this dynamic parameter

    .PARAMETER DPDictionary
        If specified, add resulting RuntimeDefinedParameter to an existing RuntimeDefinedParameterDictionary (appropriate for multiple dynamic parameters)
        If not specified, create and return a RuntimeDefinedParameterDictionary (appropriate for a single dynamic parameter)

        See final example for illustration

    .EXAMPLE

        function Show-Free
        {
            [CmdletBinding()]
            Param()
            DynamicParam {
                $options = @( gwmi win32_volume | %{$_.driveletter} | sort )
                New-DynamicParam -Name Drive -ValidateSet $options -Position 0 -Mandatory
            }
            begin{
                #have to manually populate
                $drive = $PSBoundParameters.drive
            }
            process{
                $vol = gwmi win32_volume -Filter "driveletter='$drive'"
                "{0:N2}% free on {1}" -f ($vol.Capacity / $vol.FreeSpace),$drive
            }
        } #Show-Free

        Show-Free -Drive <tab>

    # This example illustrates the use of New-DynamicParam to create a single dynamic parameter
    # The Drive parameter ValidateSet populates with all available volumes on the computer for handy tab completion / intellisense

    .EXAMPLE

    # I found many cases where I needed to add more than one dynamic parameter
    # The DPDictionary parameter lets you specify an existing dictionary
    # The block of code in the Begin block loops through bound parameters and defines variables if they don't exist

        Function Test-DynPar{
            [cmdletbinding()]
            param(
                [string[]]$x = $Null
            )
            DynamicParam
            {
                #Create the RuntimeDefinedParameterDictionary
                $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

                New-DynamicParam -Name AlwaysParam -ValidateSet @( gwmi win32_volume | %{$_.driveletter} | sort ) -DPDictionary $Dictionary

                #Add dynamic parameters to $dictionary
                if($x -eq 1)
                {
                    New-DynamicParam -Name X1Param1 -ValidateSet 1,2 -mandatory -DPDictionary $Dictionary
                    New-DynamicParam -Name X1Param2 -DPDictionary $Dictionary
                    New-DynamicParam -Name X3Param3 -DPDictionary $Dictionary -Type DateTime
                }
                else
                {
                    New-DynamicParam -Name OtherParam1 -Mandatory -DPDictionary $Dictionary
                    New-DynamicParam -Name OtherParam2 -DPDictionary $Dictionary
                    New-DynamicParam -Name OtherParam3 -DPDictionary $Dictionary -Type DateTime
                }

                #return RuntimeDefinedParameterDictionary
                $Dictionary
            }
            Begin
            {
                #This standard block of code loops through bound parameters...
                #If no corresponding variable exists, one is created
                    #Get common parameters, pick out bound parameters not in that set
                    Function _temp { [cmdletbinding()] param() }
                    $BoundKeys = $PSBoundParameters.keys | Where-Object { (get-command _temp | select -ExpandProperty parameters).Keys -notcontains $_}
                    foreach($param in $BoundKeys)
                    {
                        if (-not ( Get-Variable -name $param -scope 0 -ErrorAction SilentlyContinue ) )
                        {
                            New-Variable -Name $Param -Value $PSBoundParameters.$param
                            Write-Verbose "Adding variable for dynamic parameter '$param' with value '$($PSBoundParameters.$param)'"
                        }
                    }

                #Appropriate variables should now be defined and accessible
                    Get-Variable -scope 0
            }
        }

    # This example illustrates the creation of many dynamic parameters using New-DynamicParam
        # You must create a RuntimeDefinedParameterDictionary object ($dictionary here)
        # To each New-DynamicParam call, add the -DPDictionary parameter pointing to this RuntimeDefinedParameterDictionary
        # At the end of the DynamicParam block, return the RuntimeDefinedParameterDictionary
        # Initialize all bound parameters using the provided block or similar code

    .FUNCTIONALITY
        PowerShell Language

#>
param(
    [string]$Name,
    [System.Type]$Type = [string],
    [string[]]$Alias = @(),
	[string[]]$ValidateSet,
    [switch]$Mandatory,
    [string]$ParameterSetName="__AllParameterSets",
    [int]$Position,
    [switch]$ValueFromPipelineByPropertyName,
	[switch]$ValueFromPipeline,
	[switch]$ValueFromRemainingArguments,
    [string]$HelpMessage,
    [validatescript({
        if(-not ( $_ -is [System.Management.Automation.RuntimeDefinedParameterDictionary] -or -not $_) )
        {
            Throw "DPDictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object, or not exist"
        }
        $True
    })]$DPDictionary = $false
)
    #Create attribute object, add attributes, add to collection
        $ParamAttr = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttr.ParameterSetName = $ParameterSetName
        if($mandatory)
        {
            $ParamAttr.Mandatory = $True
        }
        if($Position -ne $null)
        {
            $ParamAttr.Position=$Position
        }
        if($ValueFromPipelineByPropertyName)
        {
            $ParamAttr.ValueFromPipelineByPropertyName = $True
        }
		if($ValueFromPipeline)
		{
			$ParamAttr.ValueFromPipeline = $True
		}
		if($ValueFromRemainingArguments)
		{
			$ParamAttr.ValueFromRemainingArguments = $True
		}
        if($HelpMessage)
        {
            $ParamAttr.HelpMessage = $HelpMessage
        }

        $AttributeCollection = New-Object 'Collections.ObjectModel.Collection[System.Attribute]'
        $AttributeCollection.Add($ParamAttr)

    #param validation set if specified
        if($ValidateSet)
        {
            $ParamOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSet
            $AttributeCollection.Add($ParamOptions)
        }

    #Aliases if specified
        if($Alias.count -gt 0) {
            $ParamAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList $Alias
            $AttributeCollection.Add($ParamAlias)
        }

    #Create the dynamic parameter
        $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($Name, $Type, $AttributeCollection)

    #Add the dynamic parameter to an existing dynamic parameter dictionary, or create the dictionary and add it
        if($DPDictionary)
        {
            $DPDictionary.Add($Name, $Parameter)
        }
        else
        {
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $Dictionary.Add($Name, $Parameter)
            $Dictionary
        }
}
#endregion

Export-ModuleMember -Function * -Alias *