<#
    .Example
    .\Create-NewStorageSpace.ps1 -PoolFriendlyName FS01Pool1 -DiskFriendlyName FS01VDUSERS -ResiliencySettingName Simple -DriveLetter U -FileSystem NTFS -AllocationUnitSize 4096 -FileSystemLabel Users
    .\Create-NewStorageSpace.ps1 -PoolFriendlyName FS01Pool1 -DiskFriendlyName FS01VDDEPARTMENT -ResiliencySettingName Simple -DriveLetter H -FileSystem NTFS -AllocationUnitSize 4096 -FileSystemLabel Department

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $PoolFriendlyName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $DiskFriendlyName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Simple","DMirror","Parity")]
    [string] $ResiliencySettingName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [char] $DriveLetter,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('FAT','FAT32','exFAT','NTFS','ReFS')]
    [string] $FileSystem,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("4096","8192","16384",'32768','65536')]
    [uint32] $AllocationUnitSize,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $FileSystemLabel
)

$ss = Get-StorageSubSystem | where-object FriendlyName -like "*Windows Storage*" 
$pool = $ss | New-StoragePool -FriendlyName $PoolFriendlyName -PhysicalDisks (Get-Physicaldisk -CanPool $true)
$vd = $pool | New-VirtualDisk -FriendlyName $DiskFriendlyName -ResiliencySettingName $ResiliencySettingName -UseMaximumSize
$vd |  Get-Disk | Initialize-Disk –Passthru | New-Partition –DriveLetter $DriveLetter –UseMaximumSize | Format-Volume -FileSystem $FileSystem -AllocationUnitSize $AllocationUnitSize -NewFileSystemLabel $FileSystemLabel
