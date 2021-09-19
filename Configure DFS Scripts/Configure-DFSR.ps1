<#
    .EXAMPLE
    c:\Configure-DFSR.ps1 -GroupName Users -FolderName Profiles -MemberOne FS01 -MemberTwo FS02 -ContentDriveLetter U -ConflictAndDeletedQuotaInMB 600 -Description "Description" -Verbose
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $GroupName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $FolderName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $MemberOne,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $MemberTwo,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [char]$ContentDriveLetter,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int] $ConflictAndDeletedQuotaInMB,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $Description
)

$contentPath = "$($ContentDriveLetter):\$FolderName"
$fullGroupName = "Rep-Full-$FolderName"
Write-Verbose "Creating new DFS-R '$fullGroupName' with server members '$MemberOne', '$MemberTwo' pointing to folders '$contentPath'"
New-DfsReplicationGroup -GroupName $fullGroupName -Description $Description| New-DfsReplicatedFolder -FolderName $FolderName  -DfsnPath $fullGroupName | Add-DfsrMember -ComputerName $MemberOne,$MemberTwo
Add-DfsrConnection -GroupName $fullGroupName -SourceComputerName $MemberOne -DestinationComputerName $MemberTwo | Format-Table *name -wrap -auto

Set-DfsrMembership -GroupName $fullGroupName -FolderName $FolderName -contentPath "$contentPath" -ComputerName $MemberOne -ConflictAndDeletedQuotaInMB $ConflictAndDeletedQuotaInMB -PrimaryMember $True -Force | Format-Table *name,*path,primary* -auto -wrap
Set-DfsrMembership -GroupName $fullGroupName -FolderName $FolderName -contentPath "$contentPath" -ComputerName $MemberTwo -ConflictAndDeletedQuotaInMB $ConflictAndDeletedQuotaInMB -Force | Format-Table *name,*path,primary* -auto -wrap
