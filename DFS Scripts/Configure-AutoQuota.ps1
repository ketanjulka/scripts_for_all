<#
    .EXAMPLE
    c:\Configure-AutoQuota.ps1 -QuotaTemplate 'Monitor 1 GB Limit' -Path @("U:\Departments","U:\Home","U:\Profiles") -VErbose

#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]  $QuotaTemplate,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]] $Path
)

$Path | ForEach-Object {
    $pth = $_
    Write-Verbose "Configuring new auto quota on path '$pth' - '$QuotaTemplate'"
    New-FsrmAutoQuota -Path $pth -Template $QuotaTemplate
}