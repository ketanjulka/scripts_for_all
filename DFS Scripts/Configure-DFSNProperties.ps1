<#
    .EXAMPLE
    c:\Configure-DFSNProperties.ps1 -DFSRootName Users -EnableAccessBasedEnumeration $true -GrantAdminAccounts 'DFS administrators' -Verbose

    .EXAMPLE
    c:\Configure-DFSNProperties.ps1 -DFSRootName Data -EnableAccessBasedEnumeration $true -GrantAdminAccounts 'DFS administrators' -Verbose

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $DFSRootName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [bool] $EnableAccessBasedEnumeration,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $GrantAdminAccounts
)

$domain = $env:USERDNSDOMAIN
$path = "\\$domain\$DFSRootName"

Write-Verbose "Enabling ABE on '$path"
Set-DfsnRoot -Path $path -EnableAccessBasedEnumeration $true

Write-Verbose "Delegating permissions on '$path' for '$GrantAdminAccounts'"
Set-DfsnRoot -Path $path -GrantAdminAccounts $GrantAdminAccounts
