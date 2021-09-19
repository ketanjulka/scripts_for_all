<#
    .EXAMPLE
    c:\Configure-DFSN.ps1 -DFSRootName Data -DFSRootType DomainV2 -TargetSRV 'FS01' -Verbose

    .EXAMPLE
    c:\Configure-DFSN.ps1 -DFSRootName Users -DFSRootType DomainV2 -TargetSRV 'FS01' -Verbose

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $DFSRootName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $DFSRootType,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $TargetSRV
)

$domain = $env:USERDNSDOMAIN
$localPath = "C:\DFSRoot\$DFSRootName"
$path = "\\$domain\$DFSRootName"
$targetPAth = "\\$TargetSRV\$DFSRootName" 
New-Item -ItemType Directory -Path $localPath | out-null
New-SmbShare -Name $DFSRootName -path $localPath | out-null

Write-Verbose "DFS-N will be configured on server '$TargetSRV' with target path '$targetPath'  with UNC path '$path'"
New-DfsnRoot -TargetPath $targetPAth -Type $DFSRootType -Path $path
