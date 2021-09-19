<#
    .EXAMPLE
    c:\Scripts\Configure-DFSRProperties.ps1 -GroupName Users -FolderName Home -MemberOne FS01 -MemberTwo FS02 -DisableCrossFileRDC

    c:\Scripts\Configure-DFSRProperties.ps1 -GroupName Users -FolderName Home -AccountName "DFS administrators" -DfsrDelegation

#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $GroupName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $FolderName,
    $MemberOne,
    $MemberTwo,
    $AccountName,
    [switch] $DisableCrossFileRDC = $False,
    [switch] $DfsrDelegation = $false
)

$contentPath = "$($ContentDriveLetter):\$FolderName"
$fullGroupName = "Rep-Full-$FolderName"

if ($DisableCrossFileRDC -eq $true){
    Write-Verbose "Disabling CrossFileRDC on GroupName '$fullGroupName' between servers '$MemberOne','$MemberTwo'"
    Set-DfsrConnection -GroupName  $fullGroupName  -DisableCrossFileRDC $true -SourceComputerName $MemberOne -DestinationComputerName $MemberTwo
    Write-Verbose "Disabling CrossFileRDC on GroupName '$fullGroupName' between servers '$MemberTwo','$MemberOne'"
    Set-DfsrConnection -GroupName  $fullGroupName  -DisableCrossFileRDC $true -SourceComputerName $MemberTwo -DestinationComputerName $MemberOne

}
elseif ($DfsrDelegation -eq $true){
    Write-Verbose "Delegating permissions on GroupName '$fullGroupName' for '$AccountName'"
    Grant-DfsrDelegation -GroupName $fullGroupName  -AccountName $AccountName -Confirm:$false -Force
}
else {
    throw "No switch declared!!"
}
