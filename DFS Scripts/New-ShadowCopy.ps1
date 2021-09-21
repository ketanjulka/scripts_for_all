[CmdletBinding()]
param
(
    [parameter(ValueFromPipeline=$True)]
    [PSObject[]] $InputObject  
)
#requires -runasadministrator

Begin
{
    Set-StrictMode -Version 4
}
Process
{
    foreach ($volume in $InputObject)
    {
        $volumeName = $volume.FileSystemLabel
        $selectedVolumeID = $volume.ObjectId
        $shadowCopyClass = [WmiClass]"root\cimv2:Win32_ShadowCopy" 
        $shadowCopyClass.Create("$selectedVolumeID", "ClientAccessible") | Out-Null
        Write-Verbose "New shadow copy for volume '$volumeName' has been created"
    }
}