<#
.Synopsis
    Author: Hope This Helps
    List files in a directory if the specified directory exists.
.DESCRIPTION
    List files in a directory if the specified directory exists.
.EXAMPLE
    Get-FilesIfDirExists -path 'c:\path' | out-gridview
.EXAMPLE
    Get-FilesIfDirExists -path 'c:\path' -recurse | out-gridview
.INPUTS
    Folder path, and whether or not you want to recurse or not.
.OUTPUTS
    Table of results
.NOTES
    Version: 1.0.0
.COMPONENT
    Hope This Helps
.ROLE
    No idea
.FUNCTIONALITY
    Convenience, helpful
#>
function Get-FilesIfDirExists
{
    [CmdletBinding(DefaultParameterSetName='Set 1',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri = 'https://www.duckduckgo.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Path Param
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   ParameterSetName='Set 1')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # Recurse Param
        [Parameter(Mandatory=$false,
                   ValueFromRemainingArguments=$false,
                   Position=1,
                   ParameterSetName='Set 1')]
        [switch]$recurse
    )

    Begin{}

    Process{
        if ($pscmdlet.ShouldProcess("$($Path)", "List")){

            $proceed = $true

            #Region check if the directory even exists. Do not continue if it doesn't.

            if( !(test-path $path)){
                write-error "Couldn't find directory"
                $proceed = $false
            }

            #endregion

            #region If we are clear to proceed, perform directory listing:
            if($proceed -eq $true){

                if(!$recurse){
                    $RecurseOrNo = $false
                }else{
                    $RecurseOrNo = $true
                }

                if($RecurseOrNo -eq $true){
                    $Files = Get-Childitem -path $Path -recurse -ErrorAction 'stop'
                }else{
                    $Files = Get-Childitem -path $Path -ErrorAction 'stop'
                }

            }else{
                Write-Verbose "Execution criteria not met, not performing further action."
            }
            #endregion

        }
    }

    End{
        return $files
    }
}