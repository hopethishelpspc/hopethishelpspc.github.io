<#
.Synopsis
    QA Status: Tested/working
    Author: Steve
    Compare two directories.
.DESCRIPTION
    Compare two directories.
.EXAMPLE
    Get-TwoDirectories -path1 'c:\path1' -path2 'c:\path2' -recurse -Verbose | Out-Gridview
.EXAMPLE
    Get-TwoDirectories -path1 'c:\path1' -path2 'c:\path2' -recurse -Verbose | Out-Gridview
.EXAMPLE
    Get-TwoDirectories -path1 'c:\path1' -path2 'c:\path2' -recurse -CaseSensitive -Verbose | Out-Gridview
.INPUTS
    Folder paths, and whether or not you want to recurse or not.
.OUTPUTS
    The difference between the directories. Return object is the compare-object results.
.NOTES
    Version: 1.1.1
.COMPONENT
    HopeThisHelps
.ROLE
    No idea
.FUNCTIONALITY
    Convenience, helpful
#>
function Get-TwoDirectories
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
        # Path1 Param
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   ParameterSetName='Set 1')]
        [ValidateNotNullOrEmpty()]
        [string]$Path1,

        # Path2 Param
        [Parameter(Mandatory=$true,
                   Position=1,
                   ParameterSetName='Set 1')]
        [ValidateNotNullOrEmpty()]
        [string]$Path2,

        # Recurse Param
        [Parameter(Mandatory=$false,
                   ValueFromRemainingArguments=$false,
                   Position=1,
                   ParameterSetName='Set 1')]
        [switch]$recurse,

        # CaseSensitive Param
        [Parameter(Mandatory=$false,
                   ValueFromRemainingArguments=$false,
                   Position=2,
                   ParameterSetName='Set 1')]
        [switch]$CaseSensitive
    )

    Begin{}

    Process{
        if ($pscmdlet.ShouldProcess("Target", "Operation")){

            #region prerequisites:
            if(!$recurse){
                $RecurseOrNo = $false
            }else{
                $RecurseOrNo = $true
            }

            if(!$CaseSensitive){
                $CheckCase = $false
            }else{
                $CheckCase = $true
            }

            $Dir1 = $Path1
            $Dir2 = $Path2

            #Save dir info in a variable for use below:
            try{
                if($RecurseOrNo -eq $true){
                    $Dir1Get = get-ChildItem -Recurse $Dir1 -ErrorAction 'stop'
                    $Dir2Get = get-ChildItem -Recurse $Dir2 -ErrorAction 'stop'
                }else{
                    $Dir1Get = get-ChildItem $Dir1 -ErrorAction 'stop'
                    $Dir2Get = get-ChildItem $Dir2 -ErrorAction 'stop'
                }
            }catch{
                Write-Error $_.Exception.Message
                write-error "Error with querying one or both directories"
                break
            }

            #List all the files in each directory (Full paths):
            $Dir1FullFilePaths = $Dir1Get.fullname
            $Dir2FullFilePaths = $Dir2Get.fullname

            #List all the files in each directory (file names only):
            $Dir1FileNames = $dir1get.Name
            $Dir2FileNames = $dir2get.Name

            #Count of files in each directory:
            $dir1count = $dir1get.count
            $dir2count = $dir2get.count

            #Measure total size of each directory (using KB for now):
            $Dir1Size = "{0:N2}" -f ( ( Get-ChildItem $dir1 -Recurse -Force | Measure-Object -Property Length -Sum ).Sum / 1KB )
            $Dir2Size = "{0:N2}" -f ( ( Get-ChildItem $dir2 -Recurse -Force | Measure-Object -Property Length -Sum ).Sum / 1KB )
            #endregion

            #Top level analysis:

            #Compare the file counts between the two directories
            if($dir1count -eq $dir2count){
                Write-Warning "Files in both directories are both identical with count of $($dir1count)"
            }else{

                #Dir1 has more files than Dir2
                if($dir1count -gt $dir2count){
                    $CountDiff = $dir1count - $dir2count
                    $Dir1FileCountReport = "Number of files in " + $Dir1 + ": " + $dir1count + " (+" + $CountDiff + ")"
                    $Dir2FileCountReport = "Number of files in " + $Dir2 + ": " + $dir2count
                }

                #Dir2 has more files than Dir1
                if($dir1count -lt $dir2count){
                    $CountDiff = $dir2count - $dir1count
                    $Dir1FileCountReport = "Number of files in " + $Dir1 + ": " + $dir1count
                    $Dir2FileCountReport = "Number of files in " + $Dir2 + ": " + $dir2count + " (+" + $CountDiff + ")"
                }

                write-warning $Dir1FileCountReport
                write-warning $Dir2FileCountReport
            }

            Write-Verbose ""

            #Compare the size of the two directories:
            if($Dir1Size -eq $Dir2Size){
                Write-Warning "Size (KB) of both directories is identical: $($Dir1Size)"
            }else{

                #Dir1 has more KB than Dir2
                if($dir1size -gt $dir2size){
                    $CountDiffKB = $Dir1Size - $Dir2Size
                    $Dir1SizeReport = "Size (KB) of " + $Dir1 + ": " + $Dir1Size + " (+" + $CountDiffKB + ")"
                    $Dir2SizeReport = "Size (KB) of " + $Dir2 + ": " + $Dir2Size
                }

                #Dir2 has more KB than Dir1
                if($dir1size -lt $dir2size){
                    $CountDiffKB = $Dir2Size - $Dir1Size
                    $Dir1SizeReport = "Size (KB) of " + $Dir1 + ": " + $Dir1Size
                    $Dir2SizeReport = "Size (KB) of " + $Dir2 + ": " + $Dir2Size + " (+" + $CountDiffKB + ")"
                }

                write-warning $Dir1SizeReport
                write-warning $Dir2SizeReport
            }

            Write-Verbose ""

            #Compare the file names between the two directories
            #https://blogs.technet.microsoft.com/heyscriptingguy/2011/10/08/easily-compare-two-folders-by-using-powershell/
            #https://ss64.com/ps/compare-object.html
            if($CheckCase -eq $true){
                Write-Warning "The following list below excludes duplicate items and is case sensitive:"
                Write-Warning "Left: $($Dir1) | Right: $($Dir2)"
                $r = Compare-Object -ReferenceObject $dir1get -DifferenceObject $Dir2Get -caseSensitive
            }else{
                Write-Warning "The following list below excludes duplicate items and ignores casing:"
                Write-Warning "Left: $($Dir1) | Right: $($Dir2)"
                $r = Compare-Object -ReferenceObject $dir1get -DifferenceObject $Dir2Get
            }
        }
    }

    End{
        return $r
    }
}

#You can keep pasting additional functions to continue building your module...