[CmdletBinding(DefaultParameterSetName = 'StorageMaxSize')]
param
(
    [parameter(ValueFromPipeline=$True)]
    [PSObject[]] $InputObject,
    [Parameter(ParameterSetName = "StorageMaxSize")]
    [int] $StorageMaxSize,
    [Parameter(ParameterSetName = "StorageVolumeSizePercentage")]
    [int] $StorageVolumeSizePercentage
)

begin
{
    Set-StrictMode -Version 4
}
process
{
    foreach ($volume in $InputObject)
    {
        $selectedVolumeSize = $volume.Size
        $selectedVolumeID = $volume.ObjectId
        $shadowStorages = Get-CimInstance -ClassName win32_shadowstorage | Where-Object {$_.Volume.DeviceID -eq $selectedVolumeID}

        if ($shadowStorages -eq $null)
        {
            $shadowStorageClass = [WmiClass]"root\cimv2:win32_ShadowStorage" 
            $shadowStorageClass.Create("$selectedVolumeID", "ClientAccessible") | Out-Null
            Write-Verbose "ShadowCopy for drive $VolumeName has been enabled"
        }
        else
        {
            $allocatedSpace = $shadowStorages.AllocatedSpace / 1MB
            $oldMAxSpace = $shadowStorages.MaxSpace / 1MB


            if ($PSCmdlet.ParameterSetName -eq 'StorageVolumeSizePercentage')
            {
                $StorageMaxSizeValue = $selectedVolumeSize / 1MB * $StorageVolumeSizePercentage / 100
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'StorageMaxSize')
            {
                $StorageMaxSizeValue = $StorageMaxSize
            }

            if ($StorageMaxSizeValue -lt "350")
            {
                Write-Error "Aborting, StorageMaxSize ($($StorageMaxSizeValue)MB) should be greater than 350MB"
                continue
            }

            if ($StorageMaxSizeValue -lt $allocatedSpace)
            {
                $message = "New max size value $($StorageMaxSizeValue)MB is smaller than old max size value $($allocatedSpace)MB `nIT WILL REMOVE OLDEST SHADOWCOPIES TO USE NEW MAX SIZE VALUE $($StorageMaxSizeValue)MB"
                if (-not $PSCmdlet.ShouldContinue($message ,$false)) 
                {
                    Write-Verbose "Aborting ShadowCopyStorage size changing"
                    continue
                }
            }

            $returnValue = @{
                DriveLetter = $Volume.DriveLetter
                Volume = $volume.FileSystemLabel
                ShadowCopyAllocatedSpaceGB = $allocatedSpace
                OldShadowCopyMaxSpaceMB = $oldMAxSpace
                NewShadowCopyMaxSpaceMB = $StorageMaxSizeValue
                DriveSize = $selectedVolumeSize
            }

            Write-Verbose "Changing shadow copy settings for volume: $selectedVolumeID - '$($volume.FileSystemLabel)'"
            & "$Env:systemRoot\System32\vssadmin.exe" resize shadowstorage /For="$selectedVolumeID" /on="$selectedVolumeID" /Maxsize=$($StorageMaxSizeValue)MB | Out-Null

            if ($LASTEXITCODE -ne 0)
            {
                Write-Error "Vssadmin end with LASTEXITCODE - $LASTEXITCODE"
                continue
            }

            Write-Output $returnValue
        }
    }
}
