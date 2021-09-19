[CmdletBinding()]
param
(
    [parameter(ValueFromPipeline=$True)]
    [PSObject[]] $InputObject
)
#requires -runasadministrator

begin
{
    Set-StrictMode -Version 4
}
process
{
    foreach ($volume in $InputObject)
    {
        $selectedVolumeID = $volume.ObjectId
        $shadowStorages = Get-CimInstance -ClassName win32_shadowstorage | Where-Object {$_.Volume.DeviceID -eq $selectedVolumeID}
        if ($shadowStorages -ne $null)
        {
            foreach ($shadowStorage in $shadowStorages)
            {
                $driveSize = $volume.Size/1GB
                $maxsize = $shadowStorage.maxSpace/1GB
                $usedSpace = $shadowStorage.usedSpace/1GB
                $allocatedSpace = $shadowStorage.AllocatedSpace/1GB
                $usedSpacePercentage = $allocatedSpace / $usedSpace

                $returnValue = @{
                    Volume  = $volume.FileSystemLabel
                    DriveLetter = $volume.DriveLetter
                    DriveSizeGB = $driveSize
                    ShadowCopyMaxSizeGB = $maxsize
                    ShadowCopyAllocatedSpaceGB = $allocatedSpace
                    ShadowCopyUsedSpaceGB = $usedSpace
                    ShadowCopyUsedSpacePercentage = $usedSpacePercentage
                }

                return $returnValue
            }
        }    
        else
        {
            Write-Verbose "Shadow Copy for volume: $selectedVolumeID - '$($volume.FileSystemLabel)' is not enabled"
        }
        
    }
}