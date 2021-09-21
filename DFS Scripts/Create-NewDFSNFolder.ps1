<#
    .Example
    .\Create-NewDFSNFolder.ps1 -DFSNPAth "Data\Departments" -TargetPAth "\\FS01\Departments" -Verbose
    VERBOSE: Creting new DFS-N Folder '\\MYDOMAIN.LOCAL\Users\Users' with TargetPath '\\MYDOMAIN.LOCAL\Users\Users'

    Path                                  State  TimeToLiveSec Properties      Description
    ----                                  -----  ------------- ----------      -----------
    \\MYDOMAIN.LOCAL\Users\Users Online 	300           Target Failback            


    .Example
    .\Create-NewDFSNFolder.ps1 -DFSNPAth "Data\Departments" -TargetPAth "\\FS02\Departments" -DfsnFolderTarget -Verbose
    VERBOSE: Adding new DFS-N Folder Target to '\\MYDOMAIN.LOCAL\Users\Profiles' with TargetPath ''

    Path                                     TargetPath         State  ReferralPriorityClass ReferralPriorityRank
    ----                                     ----------         -----  --------------------- --------------------
    \\MYDOMAIN.LOCAL\Users\Profiles 		\\FS02\U$\Users Online sitecost-normal       0          

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $DFSNPAth,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $TargetPAth,
    [switch] $DfsnFolderTarget
)
$path = "\\$env:USERDNSDOMAIN\$DFSNPAth"
if ($DfsnFolderTarget -eq $false){
    Write-Verbose "Creting new DFS-N Folder '$path' with TargetPath '$path'"
    New-DfsnFolder -Path $path -TargetPath "$TargetPAth" -EnableTargetFailback $true
}
else {
    Write-Verbose "Adding new DFS-N Folder Target to '$path' with TargetPath '$path'"
    New-DfsnFolderTarget -Path $path -TargetPath "$TargetPAth"
}
